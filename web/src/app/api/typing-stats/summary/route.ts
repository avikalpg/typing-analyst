import { NextResponse } from 'next/server';
import { supabase } from '@/utils/supabaseClient';

export async function GET(request: Request) {
	try {
		const { data: { user } } = await supabase.auth.getUser();
		console.log('User:', user);

		if (!user) {
			return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
		}

		const { data, error } = await supabase
			.from('typing_stats')
			.select(`
				COUNT(*),
				AVG((chunk_stats->>'totalWords')::float),
				AVG((chunk_stats->>'accuracy')::float),
				AVG(
					(chunk_stats->>'totalWords')::float /
					(EXTRACT(EPOCH FROM (end_timestamp::timestamp - start_timestamp::timestamp)) / 60)
				)
			`)
			.eq('user_id', user.id)
			.gte('chunk_stats->>totalWords', '5');


		if (error) {
			return NextResponse.json({ error: error.message }, { status: 500 });
		}

		return NextResponse.json({ data }, { status: 200 });
	} catch (error) {
		console.error('Server error:', error);
		return NextResponse.json({ error: 'Failed to get stats-summary' }, { status: 500 });
	}
}
