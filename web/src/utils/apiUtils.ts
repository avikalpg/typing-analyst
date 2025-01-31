import axios from "axios";

export function addParamsToUrl(url: string, params: Record<string, string>): string {
	const baseUrl = url.startsWith('http') ? url : `${window.location.origin}${url}`;
	const urlObj = new URL(baseUrl);
	Object.entries(params).forEach(([key, value]) => {
		urlObj.searchParams.append(key, value);
	});
	return urlObj.toString();
}

export class ClientApiHelper {
	headers = {
		'Content-Type': 'application/json',
	};

	static async post(url: string, data: any) {
		return axios.post(url, data);
	}

	static async get(url: string, noCache = false): Promise<{ data: any, error: Error | null }> {
		const userId = localStorage.getItem('userId');
		const endPointUrl = addParamsToUrl(url, noCache ? { 'nonce': Math.random().toString() } : {});
		const headers = {
			'Content-Type': 'application/json',
			...(noCache ? { 'Cache-Control': 'no-store' } : {}),
		}

		if (!userId) {
			window.location.href = '/login';
			return { data: null, error: new Error('Unauthorized', { cause: 'No user found.' }) };
		}

		try {
			const response = await axios.get(endPointUrl, {
				headers: headers,
			});

			return { data: response.data, error: null };
		} catch (error) {
			if (axios.isAxiosError(error) && error.response) {
				if (error.response.status === 401) {
					console.error('Unauthorized: trying to refresh token');
					try {
						const refreshResponse = await axios.post('/api/auth/refresh');
						if (!refreshResponse.data) {
							console.error('Failed to refresh token: redirecting to login');
							window.location.href = '/login';
							return { data: null, error: new Error('Unauthorized', { cause: 'Failed to refresh token' }) };
						}

						// try to fetch the data again
						const retryResponse = await axios.get(endPointUrl, {
							headers: headers,
						});

						return { data: retryResponse.data, error: null };
					} catch (retryError) {
						console.error('Failed to fetch data after refreshing token: redirecting to login');
						window.location.href = '/login';
						return { data: null, error: new Error('Unauthorized', { cause: 'Failed to fetch data after token refresh' }) };
					}
				}
				console.error('An error occurred while fetching data:', error);
				return { data: null, error: new Error(error.response.data.error || 'An error occurred') };
			}
			console.error('An unexpected error occurred:', error);
			return { data: null, error: new Error('An unexpected error occurred') };
		}
	}
}
