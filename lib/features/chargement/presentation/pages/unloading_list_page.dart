import 'package:agent_relais/features/chargement/presentation/bloc/unloading/unloading_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import '../../../../core/constants/route_constants.dart';
import '../../../../core/db/db_helper.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/network_info_impl.dart';
import '../../../auth/data/datasources/auth_local_datasource.dart';
import '../../data/datasources/chargement_remote_datasource.dart';
import '../../data/repositories/chargement_repository_impl.dart';
import '../../domain/usecases/get_chargements.dart';
import '../../domain/usecases/update_chargement.dart';
import '../widgets/chargement_card.dart';

class UnloadingListPage extends StatelessWidget {
  const UnloadingListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final dbHelper = DbHelper.instance;
    final authLocalDs = AuthLocalDataSourceImpl(
      const FlutterSecureStorage(),
      dbHelper,
    );
    final dioClient = DioClient(
      baseUrl:
          dotenv.env['BASE_URL_TRANSFERT'] ??
          'https://maracko-backend.dev.go.incubtek.com/commodities',
      accessTokenGetter: authLocalDs.getAccessToken,
    );
    final remoteDataSource = ChargementRemoteDataSource(dioClient);
    final networkInfo = NetworkInfoImpl(InternetConnection.createInstance());

    final repository = ChargementRepositoryImpl(
      remoteDataSource: remoteDataSource,
      networkInfo: networkInfo,
    );

    return BlocProvider(
      create: (context) => UnloadingBloc(
        getChargements: GetChargements(repository),
        updateChargement: UpdateChargement(repository),
        secureStorage: const FlutterSecureStorage(),
      )..add(LoadUnloadingsEvent()),
      child: const _UnloadingListView(),
    );
  }
}

class _UnloadingListView extends StatefulWidget {
  const _UnloadingListView();

  @override
  State<_UnloadingListView> createState() => _UnloadingListViewState();
}

class _UnloadingListViewState extends State<_UnloadingListView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        title: Text(
          'Déchargements',
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
              context.read<UnloadingBloc>().add(LoadUnloadingsEvent());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher (Fiche, Sticker)',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 15,
                ),
              ),
              onChanged: (value) {
                context.read<UnloadingBloc>().add(SearchUnloadingEvent(value));
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<UnloadingBloc, UnloadingState>(
              builder: (context, state) {
                if (state is UnloadingLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is UnloadingError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Erreur: ${state.message}",
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        TextButton(
                          onPressed: () {
                            context.read<UnloadingBloc>().add(
                              LoadUnloadingsEvent(),
                            );
                          },
                          child: const Text("Réessayer"),
                        ),
                      ],
                    ),
                  );
                }

                if (state is UnloadingLoaded) {
                  if (state.filteredChargements.isEmpty) {
                    return const Center(
                      child: Text("Aucun déchargement trouvé."),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.filteredChargements.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final chargement = state.filteredChargements[index];
                      return InkWell(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            RouteConstants.unloadingDetail,
                            arguments: chargement,
                          ).then((_) {
                            if (context.mounted) {
                              context.read<UnloadingBloc>().add(
                                LoadUnloadingsEvent(),
                              );
                            }
                          });
                        },
                        child: ChargementCard(chargement: chargement),
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
