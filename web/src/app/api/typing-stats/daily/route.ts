import { NextResponse } from 'next/server';
import { supabase } from '@/utils/supabaseClient';

export async function GET() {
	const { data: { user } } = await supabase.auth.getUser();

	if (!user) {
		return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
	}

	const { data, error } = await supabase
		.from('typing_stats')
		.select(`
            chunk_stats,
            start_timestamp,
            end_timestamp
        `)
		.eq('user_id', user.id)
		.gte('chunk_stats->>totalWords', '5')
		.select(`
            DATE(start_timestamp) as date,
            AVG((chunk_stats->>'accuracy')::float) as daily_accuracy,
            AVG(
                (chunk_stats->>'totalWords')::float /
                (EXTRACT(EPOCH FROM (end_timestamp::timestamp - start_timestamp::timestamp)) / 60)
            ) as daily_wpm
        `)
		.order('date', { ascending: true });

	if (error) {
		return NextResponse.json({ error: error.message }, { status: 500 });
	}

	return NextResponse.json({ data }, { status: 200 });
}
