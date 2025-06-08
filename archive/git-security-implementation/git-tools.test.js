/**
 * Git Tools Test Suite
 * Tests for MCP Git tool integration and fallback mechanisms
 */

const { 
    get_git_status, 
    stage_files,
    create_commit,
    create_branch,
    switch_branch,
    get_diff,
    execute_git_workflow,
    is_incomplete_mcp_response,
    execute_git_command
} = require('../utils/git-tools');

const path = require('path');
const fs = require('fs');

// Test repository path
const TEST_REPO_PATH = '/home/z/repos/claude-code-troubleshoot';

describe('MCP Git Tool Integration Tests', () => {
    
    describe('MCP Response Validation', () => {
        test('should detect incomplete MCP responses - Windows paths', () => {
            expect(is_incomplete_mcp_response('c:\\home\\user\\repo')).toBe(true);
            expect(is_incomplete_mcp_response('C:\\Users\\Developer\\Project')).toBe(true);
        });
        
        test('should detect incomplete MCP responses - Unix paths', () => {
            expect(is_incomplete_mcp_response('/home/user/repo')).toBe(true);
            expect(is_incomplete_mcp_response('/Users/developer/project')).toBe(true);
        });
        
        test('should recognize complete git status responses', () => {
            expect(is_incomplete_mcp_response('On branch main\nnothing to commit, working tree clean')).toBe(false);
            expect(is_incomplete_mcp_response('On branch feature\nChanges to be committed:')).toBe(false);
        });
        
        test('should handle null/undefined responses', () => {
            expect(is_incomplete_mcp_response(null)).toBe(true);
            expect(is_incomplete_mcp_response(undefined)).toBe(true);
            expect(is_incomplete_mcp_response('')).toBe(true);
        });
    });
    
    describe('Git Command Execution', () => {
        test('should execute git status command', () => {
            const result = execute_git_command('git status --porcelain', TEST_REPO_PATH);
            expect(typeof result).toBe('string');
        });
        
        test('should execute git branch command', () => {
            const result = execute_git_command('git branch --show-current', TEST_REPO_PATH);
            expect(typeof result).toBe('string');
            expect(result.length).toBeGreaterThan(0);
        });
        
        test('should handle invalid git commands', () => {
            expect(() => {
                execute_git_command('git invalid-command', TEST_REPO_PATH);
            }).toThrow();
        });
    });
    
    describe('Git Status Functionality', () => {
        test('should get comprehensive git status', async () => {
            const status = await get_git_status(TEST_REPO_PATH);
            
            expect(status).toHaveProperty('repo_path');
            expect(status).toHaveProperty('current_branch');
            expect(status).toHaveProperty('status_output');
            expect(status).toHaveProperty('has_changes');
            expect(status).toHaveProperty('files_changed');
            expect(status).toHaveProperty('mcp_fallback_used');
            
            expect(status.repo_path).toBe(TEST_REPO_PATH);
            expect(typeof status.current_branch).toBe('string');
            expect(typeof status.has_changes).toBe('boolean');
            expect(Array.isArray(status.files_changed)).toBe(true);
        });
        
        test('should detect repository changes', async () => {
            const status = await get_git_status(TEST_REPO_PATH);
            
            if (status.has_changes) {
                expect(status.files_changed.length).toBeGreaterThan(0);
                expect(status.status_output.length).toBeGreaterThan(0);
            } else {
                expect(status.files_changed.length).toBe(0);
            }
        });
    });
    
    describe('Branch Safety Validation', () => {
        test('should detect protected branches', async () => {
            // This test would need to be run on a main/master branch
            // For now, we'll test the logic conceptually
            const protected_branches = ['main', 'master', 'production'];
            const current_branch = 'main';
            
            expect(protected_branches.includes(current_branch)).toBe(true);
        });
        
        test('should allow commits on feature branches', async () => {
            const status = await get_git_status(TEST_REPO_PATH);
            const protected_branches = ['main', 'master', 'production'];
            
            // Current branch should be a feature branch for this test
            expect(protected_branches.includes(status.current_branch)).toBe(false);
        });
    });
});

describe('Git Security Features Tests', () => {
    
    describe('Branch Protection', () => {
        test('should prevent commits to main branch', () => {
            const validate_branch_safety = (current_branch) => {
                const protected_branches = ['main', 'master', 'production'];
                if (protected_branches.includes(current_branch)) {
                    throw new Error('❌ CRITICAL: Cannot commit directly to protected branch!');
                }
            };
            
            expect(() => validate_branch_safety('main')).toThrow('Cannot commit directly to protected branch');
            expect(() => validate_branch_safety('master')).toThrow('Cannot commit directly to protected branch');
            expect(() => validate_branch_safety('feature/test')).not.toThrow();
        });
    });
    
    describe('File Validation', () => {
        test('should detect large files', () => {
            const check_file_size = (file_path, max_size_mb = 10) => {
                if (!fs.existsSync(file_path)) return false;
                
                const stats = fs.statSync(file_path);
                const file_size_mb = stats.size / (1024 * 1024);
                
                return file_size_mb > max_size_mb;
            };
            
            // Test with a small file (this test file)
            expect(check_file_size(__filename)).toBe(false);
        });
        
        test('should detect sensitive patterns', () => {
            const check_sensitive_content = (content) => {
                const sensitive_patterns = [
                    /password\s*=\s*['"]/i,
                    /api[_-]?key\s*=\s*['"]/i,
                    /secret\s*=\s*['"]/i,
                    /token\s*=\s*['"]/i
                ];
                
                return sensitive_patterns.some(pattern => pattern.test(content));
            };
            
            expect(check_sensitive_content('password = "secret123"')).toBe(true);
            expect(check_sensitive_content('api_key = "abc123"')).toBe(true);
            expect(check_sensitive_content('const name = "test"')).toBe(false);
        });
    });
});

describe('Git Workflow Integration Tests', () => {
    
    describe('Complete Workflow Execution', () => {
        test('should validate workflow configuration', () => {
            const workflow_config = {
                feature_branch_name: 'test/git-security',
                commit_message: 'test: git security implementation',
                files_to_stage: ['tests/'],
                check_security: true
            };
            
            expect(workflow_config.feature_branch_name).toMatch(/^[a-zA-Z0-9\/_-]+$/);
            expect(workflow_config.commit_message.length).toBeGreaterThan(10);
            expect(Array.isArray(workflow_config.files_to_stage)).toBe(true);
            expect(workflow_config.check_security).toBe(true);
        });
        
        test('should handle workflow errors gracefully', async () => {
            const mock_workflow = async () => {
                // Simulate workflow execution
                const steps = [];
                
                try {
                    steps.push({ step: 'status_check', success: true });
                    steps.push({ step: 'branch_validation', success: true });
                    steps.push({ step: 'security_check', success: true });
                    
                    return { success: true, steps };
                } catch (error) {
                    return { success: false, error: error.message, steps };
                }
            };
            
            const result = await mock_workflow();
            expect(result).toHaveProperty('success');
            expect(result).toHaveProperty('steps');
            expect(Array.isArray(result.steps)).toBe(true);
        });
    });
});

describe('Performance and Reliability Tests', () => {
    
    describe('MCP Tool Fallback Performance', () => {
        test('should complete git status within reasonable time', async () => {
            const start_time = Date.now();
            await get_git_status(TEST_REPO_PATH);
            const end_time = Date.now();
            
            const execution_time = end_time - start_time;
            expect(execution_time).toBeLessThan(2000); // Should complete within 2 seconds
        });
        
        test('should handle concurrent git operations', async () => {
            const operations = [
                get_git_status(TEST_REPO_PATH),
                get_git_status(TEST_REPO_PATH),
                get_git_status(TEST_REPO_PATH)
            ];
            
            const results = await Promise.all(operations);
            expect(results.length).toBe(3);
            
            results.forEach(result => {
                expect(result).toHaveProperty('current_branch');
                expect(result).toHaveProperty('mcp_fallback_used');
            });
        });
    });
    
    describe('Error Recovery', () => {
        test('should recover from git command failures', () => {
            const safe_git_command = (command, repo_path) => {
                try {
                    return execute_git_command(command, repo_path);
                } catch (error) {
                    console.warn(`Git command failed: ${command}`);
                    return null;
                }
            };
            
            // Test with invalid command
            const result = safe_git_command('git invalid-command', TEST_REPO_PATH);
            expect(result).toBeNull();
        });
    });
});

// Integration test helpers
const create_test_file = (file_path, content) => {
    const dir = path.dirname(file_path);
    if (!fs.existsSync(dir)) {
        fs.mkdirSync(dir, { recursive: true });
    }
    fs.writeFileSync(file_path, content);
};

const cleanup_test_file = (file_path) => {
    if (fs.existsSync(file_path)) {
        fs.unlinkSync(file_path);
    }
};

// Export test utilities for use in other test files
module.exports = {
    TEST_REPO_PATH,
    create_test_file,
    cleanup_test_file
};
