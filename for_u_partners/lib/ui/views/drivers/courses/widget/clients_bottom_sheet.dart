import 'package:flutter/material.dart';
import 'package:for_u_partners/ui/views/drivers/courses/model/client_model.dart';
import 'package:for_u_partners/ui/views/drivers/courses/widget/client_card.dart';
import 'package:for_u_partners/ui/views/drivers/courses/widget/dialog_widget.dart';

class ClientsBottomSheet extends StatelessWidget {
  final List<ClientData> getClientsList;
  final Function() onAccept;
  final Function() onDecline;
  const ClientsBottomSheet(
      {Key? key,
        required this.getClientsList,
        required this.onAccept,
        required this.onDecline})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.2,
      maxChildSize: 0.8,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Poignée de glissement
              Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
              // Liste des clients
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: getClientsList.length,
                  itemBuilder: (context, index) {
                    final client = getClientsList[index];
                    return ClientCard(
                        client: client,
                        onAccept: () {
                          print("ff");
                          showClientPickupDialog(
                            context: context,
                            clientName: client.name,
                            onAccept: onAccept,
                            onDecline: () {
                              Navigator.pop(context);
                            },
                          );
                        },
                        onDecline: onDecline);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
