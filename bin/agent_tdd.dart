import 'dart:io';
import 'package:args/args.dart';
import 'package:agent_tdd/src/cli/cli_runner.dart';
import 'package:agent_tdd/src/cli/logger.dart';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addFlag('json', abbr: 'j', defaultsTo: true, negatable: true, help: 'Output machine-readable JSON for AI agents (default: true)')
    ..addOption('project-dir', abbr: 'd', help: 'Project root directory (default: current directory)')
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Show usage information');

  ArgResults results;
  try {
    results = parser.parse(arguments);
  } catch (e) {
    stderr.writeln('Error parsing arguments: $e');
    exit(1);
  }

  Logger.jsonOutput = results['json'] == true;

  if (results['help'] == true || results.rest.isEmpty) {
    if (Logger.jsonOutput) {
      Logger.agentJson(
        success: true,
        phase: 'IDLE',
        instructionsForAgent:
            'agent-tdd usage: agent-tdd <command> [options]. Commands: init, specs, next, verify-red, verify-green, verify-refactor, complete, status, reset.',
      );
      return;
    }
    printUsage(parser);
    return;
  }

  final projectDir = results['project-dir']?.toString() ?? Directory.current.path;

  final runner = CliRunner(projectDir: projectDir);
  final command = results.rest.first;
  final restArgs = results.rest.sublist(1);

  await runner.runCommand(command, restArgs);
}

void printUsage(ArgParser parser) {
  print('''
🤖 agent-tdd — TDD Harness & State Machine CLI for AI Agents & Developers

Usage: agent-tdd <command> [options]

Commands:
  init             Initialize agent-tdd in the current directory
  specs            Manage specs backlog (specs list, specs add "...", specs import file.md)
  next             Pick next pending spec item and enter RED phase
  verify-red       Verify test failed on assertion (RED state) & lock test files
  verify-green     Verify minimal code passes all tests (GREEN state)
  verify-refactor  Verify tests + static analysis / linter clean (REFACTOR state)
  complete         Mark spec as DONE, create Git micro-commit, advance to IDLE
  status           Show current phase, active spec, and progress summary
  reset            Reset harness state machine to IDLE

Options:
${parser.usage}
''');
}
