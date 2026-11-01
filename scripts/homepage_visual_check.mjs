import { chromium } from 'playwright';
import { mkdir } from 'node:fs/promises';

const baseUrl = process.env.STILL_BASE_URL ?? 'http://127.0.0.1:8080';
const browser = await chromium.launch({ headless: true });
const page = await browser.newPage({ viewport: { width: 390, height: 844 } });

try {
  await mkdir('artifacts', { recursive: true });
  await page.goto(baseUrl, { waitUntil: 'networkidle' });
  const viewport = page.viewportSize();
  if (!viewport) throw new Error('Browser viewport is unavailable.');

  await page.screenshot({
    path: 'artifacts/homepage-visual-check.png',
    fullPage: true,
  });

  const input = page.locator('input').last();
  const inputVisible = await input.isVisible().catch(() => false);
  if (inputVisible) {
    const box = await input.boundingBox();
    if (!box) throw new Error('Chat input has no visible bounding box.');
    const margin = 12;
    const minHeight = 44;
    if (box.x < margin || box.x + box.width > viewport.width - margin) {
      throw new Error(`Chat input is too close to a horizontal edge: ${JSON.stringify(box)}`);
    }
    if (box.height < minHeight) {
      throw new Error(`Chat input is too short: ${JSON.stringify(box)}`);
    }
    await input.screenshot({ path: 'artifacts/homepage-chat-input.png' });
    console.log(JSON.stringify({ url: page.url(), viewport, input: box }, null, 2));
  } else {
    console.log(
      JSON.stringify({
        url: page.url(),
        viewport,
        note: 'Flutter web canvas has no exposed input DOM; inspect homepage-visual-check.png.',
      }, null, 2),
    );
  }
} finally {
  await browser.close();
}
