export interface ImageGenerationConfig {
  apiKey: string;
  model: 'dall-e-2' | 'dall-e-3';
  size: '256x256' | '512x512' | '1024x1024' | '1024x1792' | '1792x1024';
  quality: 'standard' | 'hd';
  style: 'vivid' | 'natural';
  n: number;
}

export interface ImageGenerationRequest {
  prompt: string;
}

export interface GeneratedImage {
  url: string;
  revisedPrompt?: string;
}

export interface ImageGenerationResponse {
  images: GeneratedImage[];
  model: string;
  created: number;
}

export const MICROSOFT_CULTURE_PRESETS = [
  {
    label: '成长型思维',
    englishLabel: 'Growth Mindset',
    prompt:
      'A vibrant illustration representing Microsoft Growth Mindset culture: diverse people learning, growing, collaborating around technology, brain with glowing connections, upward trajectory, warm inspiring colors, modern digital art style',
  },
  {
    label: '多样性与包容',
    englishLabel: 'Diversity & Inclusion',
    prompt:
      'A beautiful diverse group of people from different backgrounds working together at Microsoft, unity and inclusion, colorful and warm, tech office environment, celebrating differences, modern digital illustration',
  },
  {
    label: '以客户为中心',
    englishLabel: 'Customer Obsession',
    prompt:
      'Microsoft customer-focused culture: technology empowering people worldwide, global network connecting individuals and organizations, helpful AI assistant aiding real humans, vibrant digital art, inspiring and warm palette',
  },
  {
    label: '统一协作',
    englishLabel: 'One Microsoft',
    prompt:
      'One Microsoft culture: seamless teamwork and collaboration, interconnected teams working across cloud platforms, unified puzzle pieces forming a whole, Microsoft blue and orange palette, modern isometric illustration style',
  },
  {
    label: '创新精神',
    englishLabel: 'Innovation',
    prompt:
      'Microsoft innovation culture: futuristic technology breakthroughs, AI and cloud computing visualization, lightbulb moments, azure blue glowing circuits and ideas emerging, dynamic and energetic digital art',
  },
  {
    label: '赋能每个人',
    englishLabel: 'Empowerment',
    prompt:
      'Microsoft mission to empower every person and every organization on the planet: people around the globe using technology to achieve more, hands reaching up empowered by digital tools, inspiring and uplifting illustration',
  },
] as const;

export const IMAGE_SIZE_OPTIONS: { label: string; value: ImageGenerationConfig['size']; models: string[] }[] = [
  { label: '256×256', value: '256x256', models: ['dall-e-2'] },
  { label: '512×512', value: '512x512', models: ['dall-e-2'] },
  { label: '1024×1024', value: '1024x1024', models: ['dall-e-2', 'dall-e-3'] },
  { label: '1024×1792 (竖版)', value: '1024x1792', models: ['dall-e-3'] },
  { label: '1792×1024 (横版)', value: '1792x1024', models: ['dall-e-3'] },
];

export async function generateImage(
  config: ImageGenerationConfig,
  request: ImageGenerationRequest,
): Promise<ImageGenerationResponse> {
  const { apiKey, model, size, quality, style, n } = config;
  const { prompt } = request;

  const body: Record<string, unknown> = {
    model,
    prompt,
    n: model === 'dall-e-3' ? 1 : n,
    size,
    response_format: 'url',
  };

  if (model === 'dall-e-3') {
    body.quality = quality;
    body.style = style;
  }

  const response = await fetch('https://api.openai.com/v1/images/generations', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${apiKey}`,
    },
    body: JSON.stringify(body),
  });

  if (!response.ok) {
    const errorData = await response.json().catch(() => ({}));
    throw new Error(
      errorData.error?.message || `图片生成请求失败，状态码 ${response.status}`,
    );
  }

  const data = await response.json();

  return {
    images: (data.data || []).map((item: { url: string; revised_prompt?: string }) => ({
      url: item.url,
      revisedPrompt: item.revised_prompt,
    })),
    model,
    created: data.created || Date.now(),
  };
}
