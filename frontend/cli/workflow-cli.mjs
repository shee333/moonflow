#!/usr/bin/env node

import { readFileSync, writeFileSync, existsSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const commands = {
  run: 'Run a workflow from a JSON file',
  validate: 'Validate a workflow JSON file',
  list: 'List available example workflows',
  generate: 'Generate MoonBit code from workflow',
  help: 'Show this help message',
};

function printHelp() {
  console.log(`
🌙 MoonFlow CLI - Workflow Execution Tool

Usage: moonflow <command> [options]

Commands:
  run <file>      Run a workflow from a JSON file
  validate <file> Validate a workflow JSON file
  list            List available example workflows
  generate <file> Generate MoonBit code from workflow

Options:
  -h, --help      Show this help message
  -v, --version   Show version number
  -o, --output    Output file (for generate command)

Examples:
  moonflow run workflow.json
  moonflow validate workflow.json
  moonflow generate workflow.json -o output.mbt
  moonflow list
`);
}

function printVersion() {
  console.log('MoonFlow CLI v0.1.0');
}

function loadWorkflow(filePath) {
  try {
    const content = readFileSync(filePath, 'utf-8');
    return JSON.parse(content);
  } catch (error) {
    console.error(`❌ Error loading workflow: ${error.message}`);
    process.exit(1);
  }
}

function validateWorkflow(workflow) {
  const errors = [];
  const warnings = [];

  if (!workflow) {
    errors.push('Workflow is empty or undefined');
    return { valid: false, errors, warnings };
  }

  if (!workflow.nodes || !Array.isArray(workflow.nodes)) {
    errors.push('Workflow must have a "nodes" array');
  }

  if (!workflow.edges || !Array.isArray(workflow.edges)) {
    errors.push('Workflow must have an "edges" array');
  }

  if (workflow.nodes) {
    workflow.nodes.forEach((node, index) => {
      if (!node.id) {
        errors.push(`Node at index ${index} missing "id"`);
      }
      if (!node.type) {
        errors.push(`Node "${node.id || index}" missing "type"`);
      }
    });
  }

  if (workflow.edges) {
    const nodeIds = new Set(workflow.nodes?.map(n => n.id) || []);
    workflow.edges.forEach((edge, index) => {
      if (!edge.source) {
        errors.push(`Edge at index ${index} missing "source"`);
      }
      if (!edge.target) {
        errors.push(`Edge at index ${index} missing "target"`);
      }
      if (edge.source && !nodeIds.has(edge.source)) {
        errors.push(`Edge "${edge.id || index}" has invalid source: ${edge.source}`);
      }
      if (edge.target && !nodeIds.has(edge.target)) {
        errors.push(`Edge "${edge.id || index}" has invalid target: ${edge.target}`);
      }
    });
  }

  return {
    valid: errors.length === 0,
    errors,
    warnings,
  };
}

function printValidationResult(result) {
  if (result.valid) {
    console.log('✅ Workflow is valid');
  } else {
    console.log('❌ Workflow validation failed:');
    result.errors.forEach(err => console.log(`  - ${err}`));
  }

  if (result.warnings.length > 0) {
    console.log('\n⚠️  Warnings:');
    result.warnings.forEach(warn => console.log(`  - ${warn}`));
  }
}

function listExamples() {
  const examplesDir = join(__dirname, 'examples');
  const examples = [
    'llm-chatbot.json',
    'http-llm-workflow.json',
    'llm-agent.json',
    'rag-workflow.json',
    'multi-step-analysis.json',
    'data-pipeline-workflow.json',
    'notification-workflow.json',
  ];

  console.log('\n📁 Available Example Workflows:\n');
  examples.forEach(name => {
    console.log(`  • ${name}`);
  });
  console.log('');
}

function generateMoonBitCode(workflow) {
  const nodes = workflow.nodes || [];
  const packageName = workflow.name?.replace(/\s+/g, '-').toLowerCase() || 'generated-workflow';

  let code = `// MoonFlow Generated Workflow: ${workflow.name || 'Untitled'}
// Generated: ${new Date().toISOString()}
// Total Nodes: ${nodes.length}

package @moonflow/{package_name}

pub fn main {
  println("Starting workflow: ${workflow.name || 'Untitled'}")
  let ctx = WorkflowContext::()

`;

  nodes.forEach((node, index) => {
    const nodeType = node.type || 'unknown';
    const nodeLabel = node.label || node.id || `Node${index}`;

    code += `  // Node ${index + 1}: ${nodeLabel} (${nodeType})
  let node_${index} = init_node("${nodeType}", "${nodeLabel}")
`;

    if (node.data) {
      Object.entries(node.data).forEach(([key, value]) => {
        if (value !== undefined && value !== null) {
          code += `  node_${index}.set_config("${key}", ${JSON.stringify(value)})
`;
        }
      });
    }

    code += `
`;
  });

  code += `  // Execute nodes in order
`;

  nodes.forEach((_, index) => {
    code += `  execute_node(node_${index}, ctx)?
`;
  });

  code += `
  println("Workflow completed successfully!")
}

`;

  return code;
}

async function runWorkflow(filePath) {
  console.log(`\n🚀 Running workflow: ${filePath}\n`);

  const workflow = loadWorkflow(filePath);
  const validation = validateWorkflow(workflow);

  printValidationResult(validation);

  if (!validation.valid) {
    process.exit(1);
  }

  console.log('\n📊 Workflow Statistics:');
  console.log(`  Nodes: ${workflow.nodes.length}`);
  console.log(`  Edges: ${workflow.edges.length}`);
  console.log('');

  console.log('⚠️  CLI execution not yet implemented.');
  console.log('   Use the web interface to execute workflows.');
  console.log('   Run: npm run dev');
  console.log('');
}

const args = process.argv.slice(2);
const command = args[0];
const filePath = args[1];

switch (command) {
  case 'run':
    if (!filePath) {
      console.error('❌ Error: Please specify a workflow file');
      console.error('   Usage: moonflow run <file>');
      process.exit(1);
    }
    if (!existsSync(filePath)) {
      console.error(`❌ Error: File not found: ${filePath}`);
      process.exit(1);
    }
    await runWorkflow(filePath);
    break;

  case 'validate':
    if (!filePath) {
      console.error('❌ Error: Please specify a workflow file');
      console.error('   Usage: moonflow validate <file>');
      process.exit(1);
    }
    if (!existsSync(filePath)) {
      console.error(`❌ Error: File not found: ${filePath}`);
      process.exit(1);
    }
    const workflow = loadWorkflow(filePath);
    const validation = validateWorkflow(workflow);
    printValidationResult(validation);
    break;

  case 'list':
    listExamples();
    break;

  case 'generate':
    if (!filePath) {
      console.error('❌ Error: Please specify a workflow file');
      console.error('   Usage: moonflow generate <file> [-o output]');
      process.exit(1);
    }
    if (!existsSync(filePath)) {
      console.error(`❌ Error: File not found: ${filePath}`);
      process.exit(1);
    }

    const workflowToGenerate = loadWorkflow(filePath);
    const code = generateMoonBitCode(workflowToGenerate);

    const outputIndex = args.indexOf('-o') !== -1 ? args.indexOf('-o') + 1 : -1;
    if (outputIndex !== -1 && args[outputIndex]) {
      writeFileSync(args[outputIndex], code);
      console.log(`✅ Generated code saved to: ${args[outputIndex]}`);
    } else {
      console.log(code);
    }
    break;

  case '-v':
  case '--version':
    printVersion();
    break;

  case '-h':
  case '--help':
  case 'help':
  default:
    if (!command || command === 'help') {
      printHelp();
    } else {
      console.error(`❌ Unknown command: ${command}`);
      console.error('   Run "moonflow help" for usage information');
      process.exit(1);
    }
}
