import 'package:stacked/stacked.dart';
import 'notifications_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';
import 'package:for_u_partners/ui/common/text_component.dart';
import 'package:for_u_partners/ui/views/drivers/notifications/widget/notification_widget.dart';

class NotificationsView extends StackedView<NotificationsViewModel> {
  const NotificationsView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    NotificationsViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: const TextComponent(
          "Notifications",
          fontsize: 18,
          textcolor: primaryColor,
          fontweight: FontWeight.bold,
        ),
        actions: [
          if (viewModel.notifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: viewModel.fetchNotifications,
            ),
        ],
      ),
      body: viewModel.isBusy
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : viewModel.hasError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 60,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      TextComponent(
                        viewModel.errorMessage,
                        fontsize: 16,
                        textcolor: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: viewModel.fetchNotifications,
                        child: const TextComponent(
                          "Réessayer",
                          textcolor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              : viewModel.notifications.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_none,
                            size: 80,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          TextComponent(
                            "Aucune notification",
                            fontsize: 16,
                            textcolor: Colors.grey,
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: viewModel.fetchNotifications,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: viewModel.notifications.length,
                        itemBuilder: (context, index) {
                          final notification = viewModel.notifications[index];
                          return notificationsCard(
                            notification,
                            onTap: () {
                              if (!notification.isRead) {
                                viewModel.markAsRead(notification.id);
                              }
                            },
                          );
                        },
                      ),
                    ),
    );
  }

  @override
  NotificationsViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      NotificationsViewModel();

  @override
  void onViewModelReady(NotificationsViewModel viewModel) {
    viewModel.initialize();
  }
}
