# Example Workflows

This directory contains example MoonFlow workflows that you can import into MoonFlow Studio.

## Available Examples

### 1. HTTP LLM Workflow (`http-llm-workflow.json`)
A simple workflow that processes HTTP requests with an LLM:
- HTTP Trigger → LLM Processor → Response
- Also logs events in parallel

### 2. Data Pipeline Workflow (`data-pipeline-workflow.json`)
A data processing pipeline:
- Timer Trigger → Database Query → Transform → Filter → Save to File
- Demonstrates sequential data processing

### 3. Notification Workflow (`notification-workflow.json`)
Multi-channel notification system:
- HTTP Trigger → Log + Email + Queue (parallel)
- Router → Response
- Demonstrates branching and aggregation

## Usage

1. Open MoonFlow Studio
2. Click "Import" button
3. Select one of these JSON files
4. The workflow will be loaded into the editor

## Creating Your Own

To create a new workflow:
1. Design your workflow using the DAG editor
2. Click "Export" to save as JSON
3. Share the JSON file with others

## Workflow Structure

Each workflow JSON has the following structure:
```json
{
  "id": "unique-workflow-id",
  "name": "Workflow Name",
  "description": "What this workflow does",
  "nodes": [...],
  "edges": [...],
  "version": "1.0.0",
  "createdAt": "ISO date string"
}
```
