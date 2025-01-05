"use client";

import { Line } from "react-chartjs-2";
import { TypingStat } from "./page";

const ChunkWPMGraph: React.FC<{ typingStats: TypingStat[] }> = ({ typingStats }) => {
	const getWpmDataFromTypingStats = (typingStats: TypingStat[]) => {
		return {
			labels: typingStats.map(stat => new Date(stat.start_timestamp).toLocaleTimeString()),
			datasets: [
				{
					label: 'WPM',
					data: typingStats.map(stat => stat.chunk_stats.totalWords * 60000 / (new Date(stat.end_timestamp).valueOf() - new Date(stat.start_timestamp).valueOf())),
					fill: false,
					borderColor: 'rgba(75, 192, 192, 1)',
					backgroundColor: 'rgba(75, 192, 192, 0.2)',
					tension: 0.1,
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
	};
	return (
		<div className='w-full'>
			<h2>Words Per Minute (WPM)</h2>
			<Line data={chartData} options={options} />
		</div>
	);
}

export default ChunkWPMGraph;