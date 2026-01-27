import 'package:agent_relais/features/transfert/presentation/bloc/loading/loading_bloc.dart';
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
import '../../../../core/utils/ussd_transport.dart';
import '../../../auth/data/datasources/auth_local_datasource.dart';
import '../../data/datasources/local/transfert_local_datasource.dart';
import '../../data/datasources/remote/transfert_remote_datasource.dart';
import '../../data/repositories/transfert_repository_impl.dart';
import '../../domain/usecases/get_remote_transferts.dart';
import '../../domain/usecases/update_transfert_usecase.dart';
import '../widgets/transfert_card.dart';

class LoadingListPage extends StatelessWidget {
  const LoadingListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final dbHelper = DbHelper.instance;
    final localDataSource = TransfertLocalDataSourceImpl(dbHelper);
    final networkInfo = NetworkInfoImpl(InternetConnection.createInstance());
    final ussdTransport = MockUssdTransport();
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
    final remoteDataSource = TransfertRemoteDataSource(dioClient);

    final repository = TransfertRepositoryImpl(
      localDataSource: localDataSource,
      remoteDataSource: remoteDataSource,
      networkInfo: networkInfo,
      ussdTransport: ussdTransport,
    );

    return BlocProvider(
      create: (context) => LoadingBloc(
        getRemoteTransferts: GetRemoteTransferts(repository),
        updateStatus: UpdateTransfertStatus(repository),
        updateRemote: UpdateTransfertRemote(repository),
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
                  if (state.filteredTransferts.isEmpty) {
                    return const Center(
                      child: Text("Aucun chargement trouvé."),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.filteredTransferts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final transfert = state.filteredTransferts[index];
                      return InkWell(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            RouteConstants.loadingDetail,
                            arguments: transfert,
                          ).then((_) {
                            if (context.mounted) {
                              context.read<LoadingBloc>().add(
                                LoadLoadingsEvent(),
                              );
                            }
                          });
                        },
                        child: TransfertCard(transfert: transfert),
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
