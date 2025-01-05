import { NextResponse } from 'next/server';
import { supabase } from '@/utils/supabaseClient';
import { Json } from '../../../../database.types';
import { convertTimestampsToISO } from '@/utils/datetime';

type TypingStat = {
	start_timestamp: number; // milliseconds since epoch
	end_timestamp: number; // milliseconds since epoch
	application: string;
	device_id: string;
	keyboard_id: string | null;
	locale: string;
	per_second_data: Json[];
	chunk_stats: Json;
};

export async function POST(request: Request) {
	try {
		// 1. Authenticate the request (using Supabase Auth)
		const { data: { user } } = await supabase.auth.getUser();

		if (!user) {
			return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
		}

		// 2. Validate the incoming data
		const typingStats: TypingStat = await request.json();

		if (
			!typingStats.start_timestamp ||
			!typingStats.end_timestamp ||
			!typingStats.application ||
			!typingStats.device_id ||
			!typingStats.locale ||
			!typingStats.per_second_data ||
			!typingStats.chunk_stats
		) {
			return NextResponse.json({ error: 'Missing required data' }, { status: 400 });
		}

		// 3. Insert the data into Supabase
		const dataToInsert = convertTimestampsToISO(typingStats);
		const { error } = await supabase
			.from('typing_stats')
			.insert({ ...dataToInsert, user_id: user.id });

		if (error) {
			console.error('Supabase error:', error);
			return NextResponse.json({ error: error.message }, { status: 500 });
		}

		return NextResponse.json({ message: `Typing stats at ${typingStats.start_timestamp} inserted successfully for user ${user.id}` }, { status: 200 });
	} catch (error) {
		console.error('Server error:', error);
		return NextResponse.json({ error: 'Failed to insert data' }, { status: 500 });
	}
}

export async function GET(request: Request) {
	try {
		// 1. Authenticate the request (using Supabase Auth)
		const { data: { user } } = await supabase.auth.getUser();

		if (!user) {
			return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
		}

		// 2. Fetch the typing statistics for the authenticated user
		const { data, error } = await supabase
			.from('typing_stats')
			.select('*')
			.eq('user_id', user.id);

		if (error) {
			console.error('Supabase error:', error);
			return NextResponse.json({ error: error.message }, { status: 500 });
		}

		return NextResponse.json({ data }, { status: 200 });
	} catch (error) {
		console.error('Server error:', error);
		return NextResponse.json({ error: 'Failed to fetch data' }, { status: 500 });
	}
}