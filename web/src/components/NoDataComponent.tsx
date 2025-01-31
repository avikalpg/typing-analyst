import React from 'react';
import { DownloadApp } from './DownloadApp';
import FAQs from './FAQs';

export const NoDataComponent = () => (
	<div className="flex flex-col items-center justify-center min-h-screen gap-8 px-4 text-center mb-12">
		<h2 className="text-2xl font-bold">No Typing Data Available</h2>
		<p className="max-w-2xl">To start tracking your typing statistics, you'll need to install and use our desktop application.</p>
		<DownloadApp />
		<FAQs />
	</div>
);