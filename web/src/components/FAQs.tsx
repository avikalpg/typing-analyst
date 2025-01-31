export default function FAQs() {
	return (
		<div className="max-w-2xl text-start">
			<h3 className="text-xl font-bold mb-4">Frequently Asked Questions</h3>
			<div className="space-y-4">
				<div>
					<h4 className="font-bold">How does it work?</h4>
					<p>Our desktop application runs in the background and securely tracks your typing patterns to help you improve your typing speed and accuracy.</p>
				</div>
				<div>
					<h4 className="font-bold">Is my data secure?</h4>
					<p>Yes! We only collect typing metrics, never the actual content you type. All data is encrypted and stored securely.</p>
				</div>
				<div>
					<h4 className="font-bold">When will I see my statistics?</h4>
					<p>Once you install and run the desktop app, type at least 5 words without a 10-second pause, and your typing statistics will appear here immediately.</p>
				</div>
				<div>
					<h4 className="font-bold">How to install the MacOS desktop application?</h4>
					<p>This app is currently <em>not notarized</em> by Apple. To open the app:</p>
					<ol className="list-decimal list-inside">
						<li>Right-click (or Control-click) on the app icon.</li>
						<li>Select &quot;Open&quot; from the context menu.</li>
						<li>You&apos;ll see a dialog box. Click &quot;Open&quot; again to confirm.</li>
					</ol>
					<p>Additionally, you will need to manually add this application to the &quot;Input Monitoring&quot; section in the Privacy &amp; Security settings:</p>
					<ol className="list-decimal list-inside">
						<li>Open &quot;System Settings&quot; (or &quot;System Preferences&quot; on older macOS versions).</li>
						<li>Go to &quot;Privacy &amp; Security&quot;.</li>
						<li>Select &quot;Input Monitoring&quot;.</li>
						<li>Click the &quot;+&quot; button.</li>
						<li>Locate and select the application named &quot;Typing Analyst&quot;.</li>
						<li>Click &quot;Open&quot; to grant the permission.</li>
					</ol>
				</div>
			</div>
		</div>
	);
}