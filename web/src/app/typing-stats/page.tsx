"use client";

import React, { useEffect, useState } from 'react';
import 'chart.js/auto';
import ChunkWPMGraph from './ChunkWPMGraph';
import ChunkAccuracyGraph from './ChunkAccuracyGraph';
import BigNumber from './BigNumber';
import { DailyStats, SummaryStats } from '../../../types/query.types';
import { ClientApiHelper } from '@/utils/apiUtils';
import { NoDataComponent } from '@/components/NoDataComponent';

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
	const [summaryLoading, setSummaryLoading] = useState(true);
	const [dailyStatsLoading, setDailyStatsLoading] = useState(true);

	useEffect(() => {
		const fetchTypingStatsSummary = async () => {
			const { data, error } = await ClientApiHelper.get<{ data: SummaryStats[] }>('/api/typing-stats/summary', true);
			if (error || !data) {
				setError(error?.message ?? "No summary statistics received.");
				return;
			}
			setSummary(data.data[0]);
			setSummaryLoading(false);
		};

		fetchTypingStatsSummary();
	}, []);

	useEffect(() => {
		const fetchTypingStatsTimelineByDay = async () => {
			const { data, error } = await ClientApiHelper.get<{ data: DailyStats[] }>('/api/typing-stats/daily', true);
			if (error || !data) {
				setError(error?.message ?? "No daily typing statistics data received.");
				return;
			}
			setDailyStat(data.data);
			setDailyStatsLoading(false);
		};

		fetchTypingStatsTimelineByDay();
	}, []);

	if (error) {
		return <div>Error: {error}</div>;
	}

	if (!dailyStatsLoading && (dailyStat.length === 0)) {
		return <NoDataComponent />;
	}

	return (
		<div className="flex flex-col items-center justify-items-center min-h-screen gap-12 sm:px-20 sm:py-4 font-[family-name:var(--font-space-mono-regular)] bg-background">
			<div className='w-3/4 flex flex-col items-center justify-center gap-4'>
				<h1 className="text-center text-xl w-full">Typing Statistics</h1>
				{summaryLoading ? (
					<div className="animate-pulse bg-gray-200 h-6 w-3/4 rounded"></div>
				) : (
					<p className='text-center w-full'>For the {summary?.chunks_5_words} chunks (out of {summary?.total_chunks} total) that have more than 5 words</p>
				)}
			</div>
			<section className='flex justify-evenly w-full flex-wrap gap-6'>
				{summaryLoading ? (
					<>
						<div className="animate-pulse bg-gray-200 h-32 w-64 rounded"></div>
						<div className="animate-pulse bg-gray-200 h-32 w-64 rounded"></div>
						<div className="animate-pulse bg-gray-200 h-32 w-64 rounded"></div>
					</>
				) : (
					<>
						<BigNumber number={summary?.avg_words ?? NaN} units="words" description="Average Words per Chunk" />
						<BigNumber number={summary?.avg_speed ?? NaN} units="WPM" description="Average Typing Speed" />
						<BigNumber number={summary?.avg_accuracy ?? NaN} units="%" description="Average Typing Accuracy" />
					</>
				)}
			</section>
			<section className='flex w-full flex-wrap align-middle justify-evenly'>
				{dailyStatsLoading ? (
					<>
						<div className="animate-pulse bg-gray-200 h-80 min-w-80 w-1/2 px-2 rounded"></div>
						<div className="animate-pulse bg-gray-200 h-80 min-w-80 w-1/2 px-2 rounded"></div>
					</>
				) : (
					<>
						<ChunkWPMGraph dailyTypingStats={dailyStat} className='min-w-80 w-1/2 px-2' />
						<ChunkAccuracyGraph dailyTypingStats={dailyStat} className='min-w-80 w-1/2 px-2' />
					</>
				)}
			</section>
		</div>
	);
};

export default TypingStatsPage;
