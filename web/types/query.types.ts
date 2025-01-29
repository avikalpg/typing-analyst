export type SummaryStats = {
	total_chunks: number;
	chunks_5_words: number;
	avg_words: number;
	total_words: number;
	avg_accuracy: number;
	avg_speed: number;
};

export type DailyStats = {
	date: string;
	total_chunks: number;
	total_words: number;
	avg_wpm: number;
	stddev_wpm: number;
	avg_accuracy: number;
	stddev_accuracy: number;
};