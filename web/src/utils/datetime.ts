export function convertTimestampsToISO(obj: any): any {
	if (typeof obj === 'number') {
		return new Date(obj).toISOString();
	} else if (Array.isArray(obj)) {
		return obj.map(convertTimestampsToISO);
	} else if (typeof obj === 'object' && obj !== null) {
		const newObj: { [key: string]: any } = {};
		for (const key in obj) {
			if (obj.hasOwnProperty(key)) {
				if (typeof obj[key] === 'number' && key.toLowerCase().includes('timestamp')) {
					newObj[key] = new Date(obj[key]).toISOString();
				} else {
					newObj[key] = convertTimestampsToISO(obj[key]); // Recurse without key check
				}
			}
		}
		return newObj;
	}
	return obj;
}