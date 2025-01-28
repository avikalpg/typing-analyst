"use client";

import React, { useEffect, useState } from 'react';
import 'chart.js/auto';
import ChunkWPMGraph from './ChunkWPMGraph';
import ChunkAccuracyGraph from './ChunkAccuracyGraph';
import BigNumber from './BigNumber';

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
	const [typingStats, setTypingStats] = useState<TypingStat[]>([]);
	const [error, setError] = useState<string | null>(null);

	useEffect(() => {
		const fetchTypingStats = async () => {
			const userId = localStorage.getItem('userId');

			if (!userId) {
				setError('Unauthorized');
				window.location.href = '/login';
				return;
			}

			const response = await fetch('/api/typing-stats', {
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

			const data = await response.json();
			setTypingStats(data.data);
		};

		fetchTypingStats();
	}, []);

	const eligibleChunks = typingStats.filter(stat => stat.chunk_stats.totalWords >= 5);

	if (error) {
		return <div>Error: {error}</div>;
	}

	return (
		<div className="flex flex-col items-center justify-items-center min-h-screen gap-16 sm:px-20 sm:py-4 font-[family-name:var(--font-space-mono-regular)] bg-background">
			<h1 className="text-xl">Typing Statistics</h1>
			<caption className='text-center'>For the {eligibleChunks.length} chunks (out of {typingStats.length} total) that have more than 5 words</caption>
			<section className='flex justify-evenly w-full flex-wrap gap-6'>
				<BigNumber
					number={eligibleChunks.reduce((acc, stat) => acc + stat.chunk_stats.totalWords, 0) / eligibleChunks.length || 0}
					units="words"
					description="Average Words per Chunk"
				/>
				<BigNumber
					number={eligibleChunks.reduce((acc, stat) => {
						const chunkStart = new Date(stat.start_timestamp);
						const chunkEnd = new Date(stat.end_timestamp);
						const chunkDurationMin = (chunkEnd.getTime() - chunkStart.getTime()) / (1000 * 60)
						const chunkSpeed = stat.chunk_stats.totalWords / chunkDurationMin
						// console.log(`chunkSpeed: ${chunkSpeed}`)
						return acc + chunkSpeed;
					}, 0) / eligibleChunks.length || 0}
					units="WPM"
					description="Average Typing Speed"
				/>
				<BigNumber
					number={parseFloat((eligibleChunks.reduce((acc, stat) => acc + stat.chunk_stats.accuracy, 0) / eligibleChunks.length || 0).toFixed(2))}
					units="%"
					description="Average Typing Accuracy"
				/>
			</section>
			<ChunkWPMGraph typingStats={typingStats} />
			<ChunkAccuracyGraph typingStats={typingStats} />
		</div>
	);
};

export default TypingStatsPage;
