"use client";

import { Line } from "react-chartjs-2";
import { Chart, TooltipItem, LegendItem, ChartDataset } from "chart.js";
import 'chart.js/auto';
import { TimeScale } from "chart.js";
import 'chartjs-adapter-date-fns';
import { TypingStat } from "./page";
import { useEffect, useState } from "react";

Chart.register(TimeScale);

const ChunkAccuracyGraph: React.FC<{ typingStats: TypingStat[] } & React.HTMLAttributes<HTMLDivElement>> = ({ typingStats, ...props }) => {
	const [graphColor, setGraphColor] = useState<string>('rgba(153, 102, 255, 1)');

	useEffect(() => {
		if (typeof window !== 'undefined') {
			const color = window.getComputedStyle(document.documentElement).getPropertyValue('--primary');
			setGraphColor(color);
		}
	}, []);

	type CustomChartDataset = ChartDataset<'line'> & { chunksCount?: number[] };

	const getAccuracyDataFromTypingStats = (typingStats: TypingStat[]) => {
		const statsByDay = typingStats.reduce((acc, stat) => {
			const date = new Date(stat.start_timestamp);
			const dateKey = date.toISOString().split('T')[0];
			const accuracy = stat.chunk_stats.accuracy;
			if (!acc[dateKey]) {
				acc[dateKey] = [];
			}
			acc[dateKey].push(accuracy);
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
					label: 'Mean Accuracy',
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
					label: 'Accuracy Range (Upper)',
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
					label: 'Accuracy Range (Lower)',
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

	const chartData = getAccuracyDataFromTypingStats(typingStats);
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
						const meanAccuracy = allDatasets[0].data[context.dataIndex] as unknown as { x: Date, y: number };
						const upperRange = allDatasets[1].data[context.dataIndex] as unknown as { x: Date, y: number };
						const lowerRange = allDatasets[2].data[context.dataIndex] as unknown as { x: Date, y: number };

						if (datasetIndex === 0 || datasetIndex === 1 || datasetIndex === 2) {
							return `Mean Accuracy: ${meanAccuracy.y.toFixed(1)}% (${lowerRange.y.toFixed(1)}% - ${upperRange.y.toFixed(1)}%) [${chunksCount} chunks]`;
						}
					}
				}
			},
			legend: {
				labels: {
					filter: (item: LegendItem) => item.text !== 'Accuracy Range (Lower)',
					generateLabels: (chart: Chart) => {
						const labels = Chart.defaults.plugins.legend.labels.generateLabels(chart)
						return labels.map(label => {
							if (label.text === 'Accuracy Range (Upper)') {
								label.text = 'Accuracy Variance (±1 StdDev)'
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
			<h2>Accuracy by Day</h2>
			<Line data={chartData} options={options} />
		</div>
	);
}

export default ChunkAccuracyGraph;