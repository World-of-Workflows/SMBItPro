const express = require('express');
const bodyParser = require('body-parser');
const { OpenAI } = require('openai');
require('dotenv').config();

const app = express();
app.use(bodyParser.json());
app.use(express.static('public')); // Serve static files from 'public' folder

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY, // Ensure you have your API key in a .env file
});

app.post('/analyze', async (req, res) => {
  const logContent = req.body.log;

  try {
    const response = await openai.chat.completions.create({
      model: 'gpt-4',
      messages: [
        {
          role: 'system',
          content:
            'You are a cybersecurity expert. Analyze the following event log for potential security issues. Provide a detailed report highlighting any anomalies, potential threats, or security breaches.',
        },
        { role: 'user', content: logContent },
      ],
      max_tokens: 500,
      temperature: 0.2,
    });

    const analysis = response.choices[0].message.content.trim();
    res.json({ analysis });
  } catch (error) {
    console.error('OpenAI API error:', error);
    res.status(500).json({ error: 'An error occurred while processing the logs.' });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
