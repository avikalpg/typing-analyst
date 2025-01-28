import React from 'react';

interface BigNumberProps {
	number: number;
	units: string;
	description: string;
}

const BigNumber: React.FC<BigNumberProps> = ({ number, units, description }) => {
	return (
		<div className="flex flex-col items-center">
			<div className="text-6xl font-bold">
				{Number.isInteger(number) ? number : number.toFixed(1)}
				<span className="text-2xl ml-2">{units}</span>
			</div>
			<div className="text-lg text-gray-500 mt-2">{description}</div>
		</div>
	);
};

export default BigNumber;
