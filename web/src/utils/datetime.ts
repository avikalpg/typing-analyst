/* eslint-disable @typescript-eslint/no-explicit-any */
export function convertTimestampsToISO(obj: any): any {
	if (typeof obj === 'number') {
		return new Date(obj).toISOString();
	} else if (Array.isArray(obj)) {
		return obj.map(convertTimestampsToISO);
	} else if (typeof obj === 'object' && obj !== null) {
		const newObj: { [key: string]: any } = {};
		for (const key in obj) {
			if (obj.hasOwnProperty(key)) {
				if ((key.toLowerCase().includes('timestamp')) || (typeof obj[key] === 'object' && obj[key] !== null)) {
					newObj[key] = convertTimestampsToISO(obj[key]);
				} else {
					newObj[key] = obj[key];
				}
			}
		}
		return newObj;
	}
	return obj;
}
/* eslint-enable @typescript-eslint/no-explicit-any */