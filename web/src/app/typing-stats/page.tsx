"use client";

import React, { useEffect, useState } from 'react';
import 'chart.js/auto';
import ChunkWPMGraph from './ChunkWPMGraph';
import ChunkAccuracyGraph from './ChunkAccuracyGraph';
import BigNumber from './BigNumber';
import { DailyStats, SummaryStats } from '../../../types/query.types';

export type TypingStat = {
	start_timestamp: string;
	end_timestamp: string;
	application: string;
	device_id: string;
	keyboard_id: string | null;
	locale: string;
	per_second_data: PerSecondData[];
	chunk_stats: {
		totalWords: number;
		totatKeystrokes: number;
		accuracy: number;
	};
};

export type PerSecondData = {
	timestamp: string;
	keystrokes: number;
	words: number;
	accuracy: number;
	backspaces: number;
	keyStates: {
		numbers: number;
		symbols: number;
		alphabets: number;
		modifiers: number;
		backspaces: number;
	}
};

const TypingStatsPage: React.FC = () => {
	const [summary, setSummary] = useState<SummaryStats | null>(null);
	const [dailyStat, setDailyStat] = useState<DailyStats[]>([]);
	const [error, setError] = useState<string | null>(null);

	useEffect(() => {
		const fetchTypingStatsSummary = async () => {
			const userId = localStorage.getItem('userId');

			if (!userId) {
				setError('Unauthorized');
				window.location.href = '/login';
				return;
			}

			const response = await fetch('/api/typing-stats/summary', {
				method: 'GET',
				headers: {
					'Content-Type': 'application/json',
				},
			});

			if (!response.ok) {
				const errorData = await response.json();
				if (response.status === 401) {
					setError('Unauthorized');
					console.error('Unauthorized: redirecting to login');
					window.location.href = '/login';
					return;
				}
				setError(errorData.error);
				return;
			}

			const data: { data: SummaryStats[] } = await response.json();
			setSummary(data.data[0]);
		};

		fetchTypingStatsSummary();
	}, []);

	useEffect(() => {
		const fetchTypingStatsTimelineByDay = async () => {
			const userId = localStorage.getItem('userId');

			if (!userId) {
				setError('Unauthorized');
				window.location.href = '/login';
				return;
			}

			const response = await fetch('/api/typing-stats/daily', {
				method: 'GET',
				headers: {
					'Content-Type': 'application/json',
				},
			});

			if (!response.ok) {
				const errorData = await response.json();
				if (response.status === 401) {
					setError('Unauthorized');
					console.error('Unauthorized: redirecting to login');
					window.location.href = '/login';
					return;
				}
				setError(errorData.error);
				return;
			}

			const data: { data: DailyStats[] } = await response.json();
			console.log(data.data);
			setDailyStat(data.data);
		};

		fetchTypingStatsTimelineByDay();
	}, []);

	if (error) {
		return <div>Error: {error}</div>;
	}

	return (
		<div className="flex flex-col items-center justify-items-center min-h-screen gap-12 sm:px-20 sm:py-4 font-[family-name:var(--font-space-mono-regular)] bg-background">
			<div className='w-3/4 flex flex-col items-center justify-center gap-4'>
				<h1 className="text-center text-xl w-full">Typing Statistics</h1>
				<p className='text-center w-full'>For the {summary?.chunks_5_words} chunks (out of {summary?.total_chunks} total) that have more than 5 words</p>
			</div>
			<section className='flex justify-evenly w-full flex-wrap gap-6'>
				<BigNumber number={summary?.avg_words ?? NaN} units="words" description="Average Words per Chunk" />
				<BigNumber number={summary?.avg_speed ?? NaN} units="WPM" description="Average Typing Speed" />
				<BigNumber number={summary?.avg_accuracy ?? NaN} units="%" description="Average Typing Accuracy" />
			</section>
			<section className='flex w-full flex-wrap align-middle justify-evenly'>
				<ChunkWPMGraph dailyTypingStats={dailyStat} className='min-w-80 w-1/2 px-2' />
				<ChunkAccuracyGraph dailyTypingStats={dailyStat} className='min-w-80 w-1/2 px-2' />
			</section>
		</div>
	);
};

export default TypingStatsPage;
