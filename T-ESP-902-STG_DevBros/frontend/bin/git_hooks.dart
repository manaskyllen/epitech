import 'dart:io';
import 'package:git_hooks/git_hooks.dart';

void main(List arguments) {
  // ignore: omit_local_variable_types
  final Map<Git, UserBackFun> params = {Git.commitMsg: commitMsg};
  GitHooks.call(arguments, params);
}

Future<bool> commitMsg() async {
  final commitMsg = Utils.getCommitEditMsg();
  if (commitMsg.startsWith('fix:')) {
    return true;
  } else if (commitMsg.startsWith('feat:')) {
    return true;
  } else if (commitMsg.startsWith('hotfix:')) {
    return true;
  } else if (commitMsg.startsWith('ci:')) {
    return true;
  } else if (commitMsg.startsWith('cd:')) {
    return true;
  } else if (commitMsg.startsWith('core:')) {
    return true;
  } else if (commitMsg.startsWith('update:')) {
    return true;
  } else {
    stderr.write(
      'error sementic you should add `fix|feat|core|update|cd|ci|hotfix| : (your commit message)`',
    );
    return false;
  }
}
