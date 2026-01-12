import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/route_constants.dart';
import '../bloc/list/transfert_list_bloc.dart';
import '../widgets/transfert_card.dart';

class TranfertsPage extends StatefulWidget {
  const TranfertsPage({super.key});

  @override
  State<TranfertsPage> createState() => _TranfertsPageState();
}

class _TranfertsPageState extends State<TranfertsPage> {
  String? selectedType;
  String? selectedStatus;

  @override
  void initState() {
    super.initState();
    // On charge la liste dès l'ouverture
    context.read<TransfertListBloc>().add(LoadTransfertsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        title: Text(
          'Demandes de transfert',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            fontSize: 16,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: () {
              context.read<TransfertListBloc>().add(LoadTransfertsEvent());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtres
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    "Tous les types",
                    ["ORDINAIRE", "INTÉRIEURE"],
                    selectedType,
                    (v) => setState(() => selectedType = v),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildDropdown(
                    "Tous les statuts",
                    [
                      "synchronisé",
                      "en_attente",
                      "draft",
                      "echec",
                      "envoyé_ussd",
                    ],
                    selectedStatus,
                    (v) => setState(() => selectedStatus = v),
                  ),
                ),
              ],
            ),
          ),

          // Liste avec BLoC
          Expanded(
            child: BlocBuilder<TransfertListBloc, TransfertListState>(
              builder: (context, state) {
                if (state is TransfertListLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is TransfertListError) {
                  return Center(
                    child: Text(
                      "Erreur: ${state.message}",
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                }

                if (state is TransfertListLoaded) {
                  // Filtrage coté UI
                  final filteredList = state.transferts.where((t) {
                    final matchesType =
                        selectedType == null || t.typeTransfert == selectedType;
                    final matchesStatus =
                        selectedStatus == null || t.status == selectedStatus;
                    return matchesType && matchesStatus;
                  }).toList();

                  if (filteredList.isEmpty) {
                    return Center(child: Text("Aucune demande trouvée."));
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) => TransfertCard(
                      transfert: filteredList[index],
                    ), // Assurez-vous que TransfertCard accepte TransfertEntity
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Color(0xFF0E8446),
        onPressed: () async {
          await Navigator.pushNamed(context, RouteConstants.addTransfert);
          // Au retour, on rafraichit la liste
          if (context.mounted) {
            context.read<TransfertListBloc>().add(LoadTransfertsEvent());
          }
        },
        label: const Text("Nouveau", style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildDropdown(
    String hint,
    List<String> items,
    String? value,
    Function(String?) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          hint: Text(hint, style: TextStyle(fontSize: 13)),
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: TextStyle(fontSize: 13)),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
