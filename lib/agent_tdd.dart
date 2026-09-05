// Package exports
export 'package:agent_harness/agent_harness.dart';
export 'package:agent_file_snapshot/agent_file_snapshot.dart';
export 'package:agent_backlog/agent_backlog.dart';

// Core exports
export 'src/core/domain/spec_item.dart';
export 'src/core/domain/tdd_config.dart';
export 'src/core/domain/tdd_state_extensions.dart';
export 'src/core/domain/executable_process_result.dart';
export 'src/core/domain/analysis_issue.dart';

export 'src/core/data/spec_store.dart';
export 'src/core/data/config_store.dart';
export 'src/core/data/snapshot_store.dart';

export 'src/core/services/processes.dart';
export 'src/core/services/test_run_verifications.dart';
export 'src/core/services/analyzer.dart';
export 'src/core/services/git_client.dart';

// Feature use case exports
export 'src/features/init/usecases/init_harness_usecase.dart';
export 'src/features/specs/usecases/list_specs_usecase.dart';
export 'src/features/specs/usecases/add_spec_usecase.dart';
export 'src/features/specs/usecases/import_specs_usecase.dart';
export 'src/features/next/usecases/start_next_cycle_usecase.dart';
export 'src/features/verify_red/usecases/verify_red_usecase.dart';
export 'src/features/verify_green/usecases/verify_green_usecase.dart';
export 'src/features/verify_refactor/usecases/verify_refactor_usecase.dart';
export 'src/features/complete/usecases/complete_cycle_usecase.dart';
export 'src/features/status/usecases/get_status_usecase.dart';
export 'src/features/reset/usecases/reset_cycle_usecase.dart';

// CLI exports
export 'src/cli/cli_runner.dart';
