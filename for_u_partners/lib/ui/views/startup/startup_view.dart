import 'startup_viewmodel.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:for_u_partners/ui/common/ui_helpers.dart';


class StartupView extends StackedView<StartupViewModel> {
  const StartupView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    StartupViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      body: Center(
        child: Image.asset("assets/logo.png", width: 200, height: 200),
      ),
    );
  }

  @override
  StartupViewModel viewModelBuilder(BuildContext context) => StartupViewModel();

  @override
  void onViewModelReady(StartupViewModel viewModel) => SchedulerBinding.instance
      .addPostFrameCallback((timeStamp) => viewModel.runStartupLogic());
}