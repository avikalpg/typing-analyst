"use client";

import React, { useEffect, useState } from 'react';
import 'chart.js/auto';
import ChunkWPMGraph from './ChunkWPMGraph';
import ChunkAccuracyGraph from './ChunkAccuracyGraph';

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

	if (error) {
		return <div>Error: {error}</div>;
	}

	return (
		<div className="flex flex-col items-center justify-items-center min-h-screen gap-16 sm:p-20 font-[family-name:var(--font-space-mono-regular)] bg-background">
			<h1>Typing Statistics</h1>
			<ChunkWPMGraph typingStats={typingStats} />
			<ChunkAccuracyGraph typingStats={typingStats} />
		</div>
	);
};

export default TypingStatsPage;
