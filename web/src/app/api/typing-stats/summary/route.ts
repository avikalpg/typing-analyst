import { NextResponse } from 'next/server';
import { supabase } from '@/utils/supabaseClient';
import conn from '@/utils/db';
import { SummaryStats } from '../../../../../types/query.types';

export async function GET(request: Request) {
	try {
		const authRes = await supabase.auth.getUser();
		console.log(authRes);
		let { data: { user } } = authRes;

		if (!user) {
			// return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
			console.warn('[typing-stats/summary] no user found. Placing a fake user id');
			user = {
				id: '20683479-157a-4313-a6e4-d7679bd1fbbf',
				aud: 'authenticated',
				role: 'authenticated',
				email: 'avikalpgupta@gmail.com',
				email_confirmed_at: '2025-01-03T11:08:41.970991Z',
				phone: '',
				confirmation_sent_at: '2025-01-03T11:07:54.25743Z',
				confirmed_at: '2025-01-03T11:08:41.970991Z',
				recovery_sent_at: '2025-01-08T19:58:40.408458Z',
				last_sign_in_at: '2025-01-29T11:44:00.986627Z',
				app_metadata: [Object],
				user_metadata: [Object],
				created_at: '2025-01-03T11:07:54.204486Z',
				updated_at: '2025-01-29T11:44:00.991102Z',
				is_anonymous: false
			}
		}

		const q = `
		SELECT
			(SELECT COUNT(*) FROM typing_stats WHERE user_id = '${user.id}') AS total_chunks,
			COUNT(*) AS chunks_5_words,
			AVG((chunk_stats->>'totalWords')::float) AS avg_words,
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
