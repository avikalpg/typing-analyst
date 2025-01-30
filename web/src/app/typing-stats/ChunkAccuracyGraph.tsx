"use client";

import { Line } from "react-chartjs-2";
import { Chart, TooltipItem, LegendItem, ChartDataset } from "chart.js";
import 'chart.js/auto';
import { TimeScale } from "chart.js";
import 'chartjs-adapter-date-fns';
import { useEffect, useState } from "react";
import { DailyStats } from "../../../types/query.types";

Chart.register(TimeScale);

const ChunkAccuracyGraph: React.FC<{ dailyTypingStats: DailyStats[] } & React.HTMLAttributes<HTMLDivElement>> = ({ dailyTypingStats, ...props }) => {
	const [graphColor, setGraphColor] = useState<string>('rgba(153, 102, 255, 1)');

	useEffect(() => {
		if (typeof window !== 'undefined') {
			const color = window.getComputedStyle(document.documentElement).getPropertyValue('--primary');
			setGraphColor(color);
		}
	}, []);

	type CustomChartDataset = ChartDataset<'line'> & { chunksCount?: number[] };

	const getAccuracyDataFromTypingStats = (dailyStatsList: DailyStats[]) => {
		const statsByDay: Record<string, { mean: number, stdDev: number, count: number }> = {};

		dailyStatsList.forEach(dailyStat => {
			const date = dailyStat.date;
			statsByDay[date] = {
				mean: dailyStat.avg_accuracy,
				stdDev: dailyStat.stddev_accuracy,
				count: dailyStat.total_chunks,
			};
		});

		const dates = Object.keys(statsByDay).sort();

		return {
			labels: dates.map(date => new Date(date)),
			datasets: [
				{
					label: 'Mean Accuracy',
					data: dates.map((date) => ({
						x: new Date(date).getTime(),
						y: Number(statsByDay[date].mean)
					})),
					fill: false,
					borderColor: graphColor,
					backgroundColor: graphColor + 20,
					tension: 0.1,
					chunksCount: dates.map(date => statsByDay[date].count),
				} as CustomChartDataset,
				{
					label: 'Accuracy Range (Upper)',
					data: dates.map((date) => ({
						x: new Date(date).getTime(),
						y: Number(statsByDay[date].mean) + Number(statsByDay[date].stdDev)
					})),
					fill: 'stack',
					borderColor: 'transparent',
					backgroundColor: graphColor + 40,
					tension: 0.1,
					chunksCount: dates.map(date => statsByDay[date].count),
				} as CustomChartDataset,
				{
					label: 'Accuracy Range (Lower)',
					data: dates.map((date) => ({
						x: new Date(date).getTime(),
						y: Number(statsByDay[date].mean) - Number(statsByDay[date].stdDev)
					})),
					fill: '-2',
					borderColor: 'transparent',
					backgroundColor: graphColor + 40,
					tension: 0.1,
					chunksCount: dates.map(date => statsByDay[date].count),
				} as CustomChartDataset,
			],
		}
	};

	const chartData = getAccuracyDataFromTypingStats(dailyTypingStats);
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
					title: (tooltipItems: TooltipItem<'line'>[]) => {
						const date = new Date(tooltipItems[0].parsed.x);
						return date.toLocaleDateString('en-US', {
							month: 'short',
							day: 'numeric',
							year: 'numeric'
						});
					},
					label: (context: TooltipItem<'line'>) => {
						const chunksCount = (context.dataset as CustomChartDataset).chunksCount?.[context.dataIndex];
						const datasetIndex = context.datasetIndex;
						const allDatasets = context.chart.data.datasets;
						const meanAccuracy = allDatasets[0].data[context.dataIndex] as { x: number, y: number };
						const upperRange = allDatasets[1].data[context.dataIndex] as { x: number, y: number };
						const lowerRange = allDatasets[2].data[context.dataIndex] as { x: number, y: number };

						if (datasetIndex === 0) {
							return `Mean Accuracy: ${meanAccuracy.y.toFixed(1)}% (${lowerRange.y.toFixed(1)}% - ${upperRange.y.toFixed(1)}%) [${chunksCount} chunks]`;
						} else if (datasetIndex === 1) {
							return `${upperRange.y.toFixed(1)}% [${chunksCount} chunks]`;
						} else if (datasetIndex === 2) {
							return `${lowerRange.y.toFixed(1)}% [${chunksCount} chunks]`;
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