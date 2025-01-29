import { NextResponse } from 'next/server';
import { supabase } from '@/utils/supabaseClient';
import conn from '@/utils/db';
import { SummaryStats } from '../../../../../types/query.types';

export async function GET(request: Request) {
	try {
		const { data: { user } } = await supabase.auth.getUser();

		if (!user) {
			return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
		}

		const q = `
		SELECT
			(SELECT COUNT(*) FROM typing_stats WHERE user_id = '${user.id}') AS total_chunks,
			COUNT(*) AS chunks_5_words,
			AVG((chunk_stats->>'totalWords')::float) AS avg_words,
			SUM((chunk_stats->>'totalWords')::float) AS total_words,
			AVG((chunk_stats->>'accuracy')::float) AS avg_accuracy,
			AVG(
				(chunk_stats->>'totalWords')::float /
				(EXTRACT(EPOCH FROM (end_timestamp::timestamp - start_timestamp::timestamp)) / 60)
			) AS avg_speed
		FROM typing_stats
		WHERE user_id='${user.id}'
			AND (chunk_stats->>'totalWords')::int > 5;
		`;

		const { data, error } = await conn.query<{ rows: SummaryStats[] }>(q)
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
	} catch (error) {
		console.error('Server error:', error);
		return NextResponse.json({ error: 'Failed to get stats-summary' }, { status: 500 });
	}
}
