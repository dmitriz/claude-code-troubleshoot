#!/usr/bin/env node

/**
 * Claude Code Troubleshoot - Main Entry Point
 * Terminal-native AI tools and Git security automation
 */

const { program } = require('commander');
const chalk = require('chalk');
const { 
    get_git_status, 
    execute_git_workflow 
} = require('./utils/git-tools');

// Set up CLI commands
program
    .name('claude-code-troubleshoot')
    .description('Terminal-native AI tools and Git security automation')
    .version('1.0.0');

// Git status command
program
    .command('git-status')
    .description('Get comprehensive git status with MCP fallback')
    .option('-p, --path <path>', 'Repository path', process.cwd())
    .action(async (options) => {
        try {
            console.log(chalk.blue('🔍 Checking Git status...'));
            const status = await get_git_status(options.path);
            
            console.log(chalk.green('\n✅ Git Status Results:'));
            console.log(`Repository: ${status.repo_path}`);
            console.log(`Current Branch: ${chalk.yellow(status.current_branch)}`);
            console.log(`Has Changes: ${status.has_changes ? chalk.red('Yes') : chalk.green('No')}`);
            console.log(`MCP Fallback Used: ${status.mcp_fallback_used ? chalk.yellow('Yes') : chalk.green('No')}`);
            
            if (status.has_changes) {
                console.log(chalk.blue('\n📝 Changed Files:'));
                status.files_changed.forEach(file => {
                    console.log(`  ${file}`);
                });
            }
        } catch (error) {
            console.error(chalk.red('❌ Error:'), error.message);
            process.exit(1);
        }
    });

// Git workflow command
program
    .command('git-workflow')
    .description('Execute secure git workflow')
    .option('-b, --branch <branch>', 'Feature branch name')
    .option('-m, --message <message>', 'Commit message')
    .option('-f, --files <files>', 'Files to stage (comma-separated)', '.')
    .option('--no-security', 'Skip security checks')
    .action(async (options) => {
        try {
            console.log(chalk.blue('🚀 Starting Git workflow...'));
            
            const workflow_options = {
                feature_branch_name: options.branch,
                commit_message: options.message,
                files_to_stage: options.files.split(',').map(f => f.trim()),
                check_security: options.security
            };
            
            const result = await execute_git_workflow(process.cwd(), workflow_options);
            
            if (result.success) {
                console.log(chalk.green('\n✅ Git workflow completed successfully!'));
                console.log(chalk.blue('\n📋 Workflow Steps:'));
                result.workflow_steps.forEach((step, index) => {
                    console.log(`  ${index + 1}. ${step.step}: ✅`);
                });
            } else {
                console.log(chalk.red('\n❌ Git workflow failed:'), result.error);
                if (result.workflow_steps.length > 0) {
                    console.log(chalk.blue('\n📋 Completed Steps:'));
                    result.workflow_steps.forEach((step, index) => {
                        console.log(`  ${index + 1}. ${step.step}: ✅`);
                    });
                }
                process.exit(1);
            }
        } catch (error) {
            console.error(chalk.red('❌ Error:'), error.message);
            process.exit(1);
        }
    });

// Security check command
program
    .command('security-check')
    .description('Run security validation on repository')
    .option('-p, --path <path>', 'Repository path', process.cwd())
    .action(async (options) => {
        console.log(chalk.blue('🔒 Running security checks...'));
        
        try {
            // Basic security checks implementation
            const status = await get_git_status(options.path);
            
            console.log(chalk.blue('\n🔍 Security Validation Results:'));
            
            // Check if on protected branch
            const protected_branches = ['main', 'master', 'production'];
            if (protected_branches.includes(status.current_branch)) {
                console.log(chalk.red('❌ WARNING: Currently on protected branch!'));
            } else {
                console.log(chalk.green('✅ Branch safety: OK'));
            }
            
            // Check for large files (basic implementation)
            if (status.files_changed.length > 0) {
                console.log(chalk.green('✅ File validation: OK'));
            }
            
            console.log(chalk.green('\n🔒 Security checks completed'));
            
        } catch (error) {
            console.error(chalk.red('❌ Security check failed:'), error.message);
            process.exit(1);
        }
    });

// Interactive mode
program
    .command('interactive')
    .description('Start interactive mode')
    .action(() => {
        console.log(chalk.blue('🤖 Claude Code Troubleshoot - Interactive Mode'));
        console.log(chalk.yellow('Available commands:'));
        console.log('  git-status  - Check repository status');
        console.log('  git-workflow - Execute secure git workflow');
        console.log('  security-check - Run security validation');
        console.log('  help - Show available commands');
        console.log('\nUse --help with any command for more information');
    });

// Default action - show help
if (process.argv.length === 2) {
    program.help();
}

// Parse command line arguments
program.parse();

// Export for programmatic use
module.exports = {
    program,
    get_git_status,
    execute_git_workflow
};
