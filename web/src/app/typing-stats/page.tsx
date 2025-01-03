"use client";

import React, { useEffect, useState } from 'react';
import { Line } from 'react-chartjs-2';
import 'chart.js/auto';

type TypingStat = {
	start_timestamp: string;
	end_timestamp: string;
	application: string;
	device_id: string;
	keyboard_id: string | null;
	locale: string;
	per_second_data: any[];
	chunk_stats: {
		wpm: number;
		accuracy: number;
	};
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

	const wpmData = {
		labels: typingStats.map(stat => new Date(stat.start_timestamp).toLocaleDateString()),
		datasets: [
			{
				label: 'WPM',
				data: typingStats.map(stat => stat.chunk_stats.wpm),
				borderColor: 'rgba(75, 192, 192, 1)',
				backgroundColor: 'rgba(75, 192, 192, 0.2)',
			},
		],
	};

	const accuracyData = {
		labels: typingStats.map(stat => new Date(stat.start_timestamp).toLocaleDateString()),
		datasets: [
			{
				label: 'Accuracy',
				data: typingStats.map(stat => stat.chunk_stats.accuracy),
				borderColor: 'rgba(153, 102, 255, 1)',
				backgroundColor: 'rgba(153, 102, 255, 0.2)',
			},
		],
	};

	if (error) {
		return <div>Error: {error}</div>;
	}

	return (
		<div>
			<h1>Typing Statistics</h1>
			<div>
				<h2>Words Per Minute (WPM)</h2>
				<Line data={wpmData} />
			</div>
			<div>
				<h2>Accuracy</h2>
				<Line data={accuracyData} />
			</div>
		</div>
	);
};

export default TypingStatsPage;
