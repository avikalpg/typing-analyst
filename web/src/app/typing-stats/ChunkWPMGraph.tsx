"use client";

import { Line } from "react-chartjs-2";
import { TypingStat } from "./page";

const ChunkWPMGraph: React.FC<{ typingStats: TypingStat[] } & React.HTMLAttributes<HTMLDivElement>> = ({ typingStats, ...props }) => {
	const getWpmDataFromTypingStats = (typingStats: TypingStat[]) => {
		const statsByDay = typingStats.reduce((acc, stat) => {
			const date = new Date(stat.start_timestamp).toLocaleDateString();
			const wpm = stat.chunk_stats.totalWords * 60000 / (new Date(stat.end_timestamp).valueOf() - new Date(stat.start_timestamp).valueOf());
			if (!acc[date]) {
				acc[date] = [];
			}
			acc[date].push(wpm);
			return acc;
		}, {} as Record<string, number[]>);

		const calculateStats = (values: number[]) => {
			const mean = values.reduce((sum, val) => sum + val, 0) / values.length;
			const variance = values.reduce((sum, val) => sum + Math.pow(val - mean, 2), 0) / values.length;
			const stdDev = Math.sqrt(variance);
			return { mean, stdDev, count: values.length };
		};

		const dates = Object.keys(statsByDay).sort();
		const stats = dates.map(date => calculateStats(statsByDay[date]));

		return {
			labels: dates,
			datasets: [
				{
					label: 'Mean WPM',
					data: stats.map(stat => stat.mean),
					fill: false,
					borderColor: 'rgba(75, 192, 192, 1)',
					backgroundColor: 'rgba(75, 192, 192, 0.2)',
					tension: 0.1,
					chunksCount: stats.map(stat => stat.count),
				},
				{
					label: 'WPM Range (±1 StdDev)',
					data: stats.map(stat => stat.stdDev),
					fill: true,
					borderColor: 'transparent',
					backgroundColor: 'rgba(75, 192, 192, 0.1)',
					tension: 0.1,
					chunksCount: stats.map(stat => stat.count),
				},
			],
		}
	};

	const chartData = getWpmDataFromTypingStats(typingStats);
	const options = {
		scales: {
			y: {
				beginAtZero: true,
			},
		},
		plugins: {
			tooltip: {
				callbacks: {
					label: (context: any) => {
						const chunksCount = context.dataset.chunksCount[context.dataIndex];
						if (context.datasetIndex === 0) {
							return `Mean WPM: ${context.raw.toFixed(1)} (${chunksCount} chunks)`;
						} else {
							return `Standard Deviation: ±${context.raw.toFixed(1)} (${chunksCount} chunks)`;
						}
					}
				}
			}
		}
	};

	return (
		<div className='w-full' {...props}>
			<h2>Words Per Minute (WPM) by Day</h2>
			<Line data={chartData} options={options} />
		</div>
	);
}
export default ChunkWPMGraph;