import { NextResponse } from 'next/server';
import { supabase } from '@/utils/supabaseClient';
import { DailyStats } from '../../../../../types/query.types';
import conn from '@/utils/db';

export async function GET() {
	const { data: { user } } = await supabase.auth.getUser();

	if (!user) {
		return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
	}

	const q = `
		select
			DATE(start_timestamp) as date,
			count(*) as total_chunks,
			sum(cast(chunk_stats->>'totalWords' as integer)) as total_words,
			AVG(
				(chunk_stats->>'totalWords')::float /
				(EXTRACT(EPOCH from (end_timestamp::timestamp - start_timestamp::timestamp)) / 60)
			) as avg_wpm,
			STDDEV(
				(chunk_stats->>'totalWords')::float /
				(EXTRACT(EPOCH from (end_timestamp::timestamp - start_timestamp::timestamp)) / 60)
			) as stddev_wpm,
			avg(cast(chunk_stats->>'accuracy' as decimal)) as avg_accuracy,
			STDDEV(cast(chunk_stats->>'accuracy' as decimal)) as stddev_accuracy
		from typing_stats
		where cast(chunk_stats->>'totalWords' as integer) > 5
		and user_id='${user.id}'
		group by date
		order by date;
		`;

	const { data, error } = await conn.query<{ rows: DailyStats[] }>(q)
		.then(data => {
			return { data, error: null }
		})
		.catch(error => {
			console.error(`[typing-stats/summary] Error getting stat summary for ${user.id}`, error);
			return { data: null, error }
		})

	if (error || !data) {
		return NextResponse.json({ error: error.message }, { status: 500 });
	}

	return NextResponse.json({ data: data.rows }, { status: 200 });
}
