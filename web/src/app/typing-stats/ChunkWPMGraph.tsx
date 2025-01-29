"use client";

import { Line } from "react-chartjs-2";
import { Chart, ChartDataset, LegendItem, TooltipItem } from "chart.js";
import 'chart.js/auto';
import { TimeScale } from "chart.js";
import 'chartjs-adapter-date-fns';
import { TypingStat } from "./page";
import { useEffect, useState } from "react";

Chart.register(TimeScale);

const ChunkWPMGraph: React.FC<{ typingStats: TypingStat[] } & React.HTMLAttributes<HTMLDivElement>> = ({ typingStats, ...props }) => {
	const [graphColor, setGraphColor] = useState<string>('rgba(75, 192, 192, 1)');

	useEffect(() => {
		if (typeof window !== 'undefined') {
			const color = window.getComputedStyle(document.documentElement).getPropertyValue('--secondary');
			setGraphColor(color);
		}
	}, []);

	type CustomChartDataset = ChartDataset<'line'> & { chunksCount?: number[] };

	const getWpmDataFromTypingStats = (typingStats: TypingStat[]) => {
		const statsByDay = typingStats.reduce((acc, stat) => {
			const date = new Date(stat.start_timestamp);
			const dateKey = date.toISOString().split('T')[0];
			const wpm = stat.chunk_stats.totalWords * 60000 / (new Date(stat.end_timestamp).valueOf() - new Date(stat.start_timestamp).valueOf());
			if (!acc[dateKey]) {
				acc[dateKey] = [];
			}
			acc[dateKey].push(wpm);
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
			labels: dates.map(date => new Date(date)),
			datasets: [
				{
					label: 'Mean WPM',
					data: dates.map((date, i) => ({
						x: new Date(date).getTime(),
						y: stats[i].mean
					})),
					fill: false,
					borderColor: graphColor,
					backgroundColor: graphColor + 20,
					tension: 0.1,
					chunksCount: stats.map(stat => stat.count),
				} as CustomChartDataset,
				{
					label: 'WPM Range (Upper)',
					data: dates.map((date, i) => ({
						x: new Date(date).getTime(),
						y: stats[i].mean + stats[i].stdDev
					})),
					fill: 'stack',
					borderColor: 'transparent',
					backgroundColor: graphColor + 40,
					tension: 0.1,
					chunksCount: stats.map(stat => stat.count),
				} as CustomChartDataset,
				{
					label: 'WPM Range (Lower)',
					data: dates.map((date, i) => ({
						x: new Date(date).getTime(),
						y: stats[i].mean - stats[i].stdDev
					})),
					fill: '-2',
					borderColor: 'transparent',
					backgroundColor: graphColor + 40,
					tension: 0.1,
					chunksCount: stats.map(stat => stat.count),
				} as CustomChartDataset,
			],
		}
	};
	const chartData = getWpmDataFromTypingStats(typingStats);
	const options = {
		scales: {
			x: {
				type: 'time' as const,
				time: {
					unit: 'day' as const,
					displayFormats: {
						day: 'MMM d'
					}
				},
				ticks: {
					source: 'auto' as const,
					autoSkip: false
				}
			},
			y: {
				beginAtZero: true,
			},
		},
		plugins: {
			tooltip: {
				callbacks: {
					label: (context: TooltipItem<'line'>) => {
						const chunksCount = (context.dataset as CustomChartDataset).chunksCount?.[context.dataIndex];
						const datasetIndex = context.datasetIndex;
						const allDatasets = context.chart.data.datasets;
						const meanWPM = allDatasets[0].data[context.dataIndex] as unknown as { x: Date, y: number };
						const upperRange = allDatasets[1].data[context.dataIndex] as unknown as { x: Date, y: number };
						const lowerRange = allDatasets[2].data[context.dataIndex] as unknown as { x: Date, y: number };

						if (datasetIndex === 0 || datasetIndex === 1 || datasetIndex === 2) {
							return `Mean WPM: ${meanWPM.y.toFixed(1)} (${lowerRange.y.toFixed(1)} - ${upperRange.y.toFixed(1)}) [${chunksCount} chunks]`;
						}
					}
				}
			},
			legend: {
				labels: {
					filter: (item: LegendItem) => item.text !== 'WPM Range (Lower)',
					generateLabels: (chart: Chart) => {
						const labels = Chart.defaults.plugins.legend.labels.generateLabels(chart)
						return labels.map(label => {
							if (label.text === 'WPM Range (Upper)') {
								label.text = 'WPM Variance (±1 StdDev)'
							}
							return label
						})
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