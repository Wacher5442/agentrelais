import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/constants/route_constants.dart';
import '../../../../core/db/db_helper.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/network_info_impl.dart';
import '../../../auth/data/datasources/auth_local_datasource.dart';
import '../../data/datasources/chargement_remote_datasource.dart';
import '../../data/repositories/chargement_repository_impl.dart';
import '../../domain/usecases/get_chargements.dart';
import '../../domain/usecases/update_chargement.dart';
import '../bloc/loading/loading_bloc.dart';
import '../widgets/chargement_card.dart';

class LoadingListPage extends StatelessWidget {
  const LoadingListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // DI Setup
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
      create: (context) => LoadingBloc(
        getChargements: GetChargements(repository),
        updateChargementStatus: UpdateChargementStatus(repository),
        updateChargement: UpdateChargement(repository),
      )..add(LoadLoadingsEvent()),
      child: const _LoadingListView(),
    );
  }
}

class _LoadingListView extends StatefulWidget {
  const _LoadingListView();

  @override
  State<_LoadingListView> createState() => _LoadingListViewState();
}

class _LoadingListViewState extends State<_LoadingListView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        title: Text(
          'Chargements',
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
              context.read<LoadingBloc>().add(LoadLoadingsEvent());
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
                context.read<LoadingBloc>().add(SearchLoadingEvent(value));
              },
            ),
          ),

          Expanded(
            child: BlocBuilder<LoadingBloc, LoadingState>(
              builder: (context, state) {
                if (state is LoadingLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is LoadingError) {
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
                            context.read<LoadingBloc>().add(
                              LoadLoadingsEvent(),
                            );
                          },
                          child: const Text("Réessayer"),
                        ),
                      ],
                    ),
                  );
                }

                if (state is LoadingLoaded) {
                  if (state.filteredChargements.isEmpty) {
                    return const Center(
                      child: Text("Aucun chargement trouvé."),
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
                            RouteConstants.loadingDetail,
                            arguments: chargement,
                          ).then((_) {
                            if (context.mounted) {
                              context.read<LoadingBloc>().add(
                                LoadLoadingsEvent(),
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
