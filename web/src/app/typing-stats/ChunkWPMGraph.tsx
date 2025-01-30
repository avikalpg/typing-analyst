"use client";

import { Line } from "react-chartjs-2";
import { Chart, ChartDataset, LegendItem, TooltipItem } from "chart.js";
import 'chart.js/auto';
import { TimeScale } from "chart.js";
import 'chartjs-adapter-date-fns';
import { useEffect, useState } from "react";
import { DailyStats } from "../../../types/query.types";

Chart.register(TimeScale);

const ChunkWPMGraph: React.FC<{ dailyTypingStats: DailyStats[] } & React.HTMLAttributes<HTMLDivElement>> = ({ dailyTypingStats, ...props }) => {
	const [graphColor, setGraphColor] = useState<string>('rgba(75, 192, 192, 1)');

	useEffect(() => {
		if (typeof window !== 'undefined') {
			const color = window.getComputedStyle(document.documentElement).getPropertyValue('--accent');
			setGraphColor(color);
		}
	}, []);

	type CustomChartDataset = ChartDataset<'line'> & { chunksCount?: number[] };

	const getWpmDataFromTypingStats = (dailyStatsList: DailyStats[]) => {
		const statsByDay: Record<string, { mean: number, stdDev: number, count: number }> = {};

		dailyStatsList.forEach(dailyStat => {
			const date = dailyStat.date;
			statsByDay[date] = {
				mean: dailyStat.avg_wpm,
				stdDev: dailyStat.stddev_wpm,
				count: dailyStat.total_chunks,
			};
		});

		const dates = Object.keys(statsByDay).sort();

		return {
			labels: dates.map(date => new Date(date)),
			datasets: [
				{
					label: 'Mean WPM',
					data: dates.map((date) => ({
						x: new Date(date).getTime(),
						y: statsByDay[date].mean
					})),
					fill: false,
					borderColor: graphColor,
					backgroundColor: graphColor + 20,
					tension: 0.1,
					chunksCount: dates.map(date => statsByDay[date].count),
				} as CustomChartDataset,
				{
					label: 'WPM Range (Upper)',
					data: dates.map((date) => ({
						x: new Date(date).getTime(),
						y: statsByDay[date].mean + statsByDay[date].stdDev
					})),
					fill: 'stack',
					borderColor: 'transparent',
					backgroundColor: graphColor + 40,
					tension: 0.1,
					chunksCount: dates.map(date => statsByDay[date].count),
				} as CustomChartDataset,
				{
					label: 'WPM Range (Lower)',
					data: dates.map((date) => ({
						x: new Date(date).getTime(),
						y: statsByDay[date].mean - statsByDay[date].stdDev
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
	const chartData = getWpmDataFromTypingStats(dailyTypingStats);
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
						const meanWPM = allDatasets[0].data[context.dataIndex] as unknown as { x: Date, y: number };
						const upperRange = allDatasets[1].data[context.dataIndex] as unknown as { x: Date, y: number };
						const lowerRange = allDatasets[2].data[context.dataIndex] as unknown as { x: Date, y: number };

						if (datasetIndex === 0) {
							return `Mean speed: ${meanWPM.y.toFixed(1)} WPM (range: ${lowerRange.y.toFixed(1)}-${upperRange.y.toFixed(1)} ) [${chunksCount} chunks]`;
						} else if (datasetIndex === 1) {
							return `${upperRange.y.toFixed(1)} WPM [${chunksCount} chunks]`;
						} else if (datasetIndex === 2) {
							return `${lowerRange.y.toFixed(1)} WPM [${chunksCount} chunks]`;
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