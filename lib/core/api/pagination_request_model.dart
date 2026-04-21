import 'package:bonoos/core/api/pagination_model.dart';
import 'package:flutter/cupertino.dart';

class PaginationRequestModel {
  String? search;
  int? pageSize;
  int? page;

  PaginationRequestModel({this.search, this.pageSize = 25, this.page = 1});

  PaginationRequestModel copyWith({String? search, int? pageSize, int? page}) {
    return PaginationRequestModel(
      search: search ?? this.search,
      pageSize: pageSize ?? this.pageSize,
      page: page ?? this.page,
    );
  }
}

class UniversalPaginationHandler {
  PaginationModel? _paginationModel;
  PaginationRequestModel? _pagination = PaginationRequestModel();
  final Function(PaginationRequestModel pagination) fetch;

  UniversalPaginationHandler(
    this.fetch, {
    PaginationModel? paginationModel,
    PaginationRequestModel? pagination,
    bool initGet = false,
  }) {
    _paginationModel = paginationModel;
    if (pagination != null) {
      _pagination = pagination;
    }
    initGet ? fetch(_pagination ?? PaginationRequestModel()) : null;
  }

  set pageSize(int value) {
    _pagination = _pagination!.copyWith(pageSize: value);
  }

  set paginationModel(PaginationModel? value) => _paginationModel = value;

  int? get currentPage => _pagination?.page;

  set currentPage(int? value) {
    _pagination = _pagination?.copyWith(page: value);
  }

  Future<void> initial() async {
    fetch(_pagination ?? PaginationRequestModel());
  }

  Future<void> onRefresh() async {
    currentPage = 1;
    fetch(_pagination ?? PaginationRequestModel());
  }

  T? shouldFetch<T>({T? Function(bool shouldFetch)? onDecision}) {
    if (_paginationModel == null) return null;
    return onDecision?.call((_paginationModel?.results.length ?? 0) < (_paginationModel?.count ?? 0));
  }

  Future<void> fetchMore() async {
    shouldFetch<void>(
      onDecision: (shouldFetch) {
        if (shouldFetch) {
          currentPage = (currentPage ?? 0) + 1;
          fetch(_pagination ?? PaginationRequestModel());
        }
      },
    );
  }

  Widget buildPaginationWidget() {
    return shouldFetch<Widget>(
          onDecision: (shouldFetch) {
            if (shouldFetch) {
              currentPage = (currentPage ?? 0) + 1;
              fetch(_pagination ?? PaginationRequestModel());

              return Padding(padding: const EdgeInsets.symmetric(vertical: 16.0), child: CupertinoActivityIndicator());
            } else {
              return SizedBox();
            }
          },
        ) ??
        SizedBox();
  }
}

extension PaginationModelExt on UniversalPaginationHandler {
  Widget buildPaginatedListSep({
    key,
    required IndexedWidgetBuilder itemBuilder,
    required IndexedWidgetBuilder separatorBuilder,
    required int itemCount,
    ScrollPhysics? physics,
    Widget Function()? buildPaginationWidget,
    EdgeInsetsGeometry padding = const EdgeInsets.all(8),
  }) {
    return MyListView.separated(
      key: key,
      itemBuilder: itemBuilder,
      separatorBuilder: separatorBuilder,
      itemCount: itemCount,
      physics: physics,
      buildPaginationWidget: buildPaginationWidget ?? this.buildPaginationWidget,
      padding: padding,
    );
  }
}

class MyListView extends ListView {
  MyListView.separated({
    super.key,
    required IndexedWidgetBuilder itemBuilder,
    required super.separatorBuilder,
    required int itemCount,
    super.physics,
    required Widget Function() buildPaginationWidget,
    EdgeInsetsGeometry super.padding = const EdgeInsets.all(8),
  }) : super.separated(
         itemBuilder: (context, index) {
           if (index == itemCount) {
             return buildPaginationWidget();
           }
           return itemBuilder(context, index);
         },
         itemCount: itemCount + 1,
       );
}
