"use client";

import { Line } from "react-chartjs-2";
import { TypingStat } from "./page";

const ChunkAccuracyGraph: React.FC<{ typingStats: TypingStat[] } & React.HTMLAttributes<HTMLDivElement>> = ({ typingStats, ...props }) => {
	const getAccuracyDataFromTypingStats = (typingStats: TypingStat[]) => ({
		labels: typingStats.map(stat => new Date(stat.start_timestamp).toLocaleTimeString()),
		datasets: [
			{
				label: 'Accuracy',
				data: typingStats.map(stat => stat.chunk_stats.accuracy),
				borderColor: 'rgba(153, 102, 255, 1)',
				backgroundColor: 'rgba(153, 102, 255, 0.2)',
			},
		],
	});

	const chartData = getAccuracyDataFromTypingStats(typingStats);
	const options = {
		scales: {
			y: {
				beginAtZero: true,
			},
		},
	};
	return (
		<div className='w-full' {...props}>
			<h2>Accuracy</h2>
			<Line data={chartData} options={options} />
		</div>
	);
}

export default ChunkAccuracyGraph;