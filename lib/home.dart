import 'dart:math' as math;

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:reply/model/router_provider.dart';

import 'bottom_drawer.dart';
import 'colors.dart';
import 'compose_page.dart';
import 'mail_view_router.dart';
import 'model/email_store.dart';
import 'router.dart';
import 'settings_bottom_sheet.dart';
import 'waterfall_notched_rectangle.dart';

const _assetsPackage = 'flutter_gallery_assets';
const _iconAssetLocation = 'reply/icons';
const _folderIconAssetLocation = '$_iconAssetLocation/twotone_folder.png';
final mobileMailNavKey = GlobalKey<NavigatorState>();
const double _kFlingVelocity = 2.0;
const _kAnimationDuration = Duration(milliseconds: 300);

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late final AnimationController _drawerController;
  late final AnimationController _dropArrowController;
  late final AnimationController _bottomAppBarController;
  late final Animation<double> _drawerCurve;
  late final Animation<double> _dropArrowCurve;
  late final Animation<double> _bottomAppBarCurve;

  final _bottomDrawerKey = GlobalKey(debugLabel: 'Bottom Drawer');
  final _navigationDestinations = const <_Destination>[
    _Destination(
      name: 'Inbox',
      icon: '$_iconAssetLocation/twotone_inbox.png',
      index: 0,
    ),
    _Destination(
      name: 'Starred',
      icon: '$_iconAssetLocation/twotone_star.png',
      index: 1,
    ),
    _Destination(
      name: 'Sent',
      icon: '$_iconAssetLocation/twotone_send.png',
      index: 2,
    ),
    _Destination(
      name: 'Trash',
      icon: '$_iconAssetLocation/twotone_delete.png',
      index: 3,
    ),
    _Destination(
      name: 'Spam',
      icon: '$_iconAssetLocation/twotone_error.png',
      index: 4,
    ),
    _Destination(
      name: 'Drafts',
      icon: '$_iconAssetLocation/twotone_drafts.png',
      index: 5,
    ),
  ];

  final _folders = <String, String>{
    'Receipts': _folderIconAssetLocation,
    'Pine Elementary': _folderIconAssetLocation,
    'Taxes': _folderIconAssetLocation,
    'Vacation': _folderIconAssetLocation,
    'Mortgage': _folderIconAssetLocation,
    'Freelance': _folderIconAssetLocation,
  };

  @override
  void initState() {
    super.initState();

    _drawerController = AnimationController(
      duration: _kAnimationDuration,
      value: 0,
      vsync: this,
    )..addListener(() {
        if (_drawerController.status == AnimationStatus.dismissed &&
            _drawerController.value == 0) {
          Provider.of<EmailStore>(
            context,
            listen: false,
          ).bottomDrawerVisible = false;
        }

        if (_drawerController.value < 0.01) {
          setState(() {
            //Reload state when drawer is at its smallest to toggle visibility
            //If state is reloaded before this drawer closes abruptly instead
            //of animating.
          });
        }
      });

    _dropArrowController = AnimationController(
      duration: _kAnimationDuration,
      vsync: this,
    );

    _bottomAppBarController = AnimationController(
      vsync: this,
      value: 1,
      duration: const Duration(milliseconds: 250),
    );

    _drawerCurve = CurvedAnimation(
      parent: _drawerController,
      curve: standardEasing,
      reverseCurve: standardEasing.flipped,
    );

    _dropArrowCurve = CurvedAnimation(
      parent: _dropArrowController,
      curve: standardEasing,
      reverseCurve: standardEasing.flipped,
    );

    _bottomAppBarCurve = CurvedAnimation(
      parent: _bottomAppBarController,
      curve: standardEasing,
      reverseCurve: standardEasing.flipped,
    );
  }

  @override
  void dispose() {
    _drawerController.dispose();
    _dropArrowController.dispose();
    _bottomAppBarController.dispose();
    super.dispose();
  }

  void _onDestinationSelected(String destination) {
    var emailStore = Provider.of<EmailStore>(
      context,
      listen: false,
    );

    if (emailStore.onMailView) {
      emailStore.currentlySelectedEmailId = -1;
    }

    if (emailStore.currentlySelectedInbox != destination) {
      emailStore.currentlySelectedInbox = destination;
    }

    setState(() {});
  }

  bool get _bottomDrawerVisible {
    final status = _drawerController.status;
    return status == AnimationStatus.completed ||
        status == AnimationStatus.forward;
  }

  void _toggleBottomDrawerVisibility() {
    if (_drawerController.value < 0.4) {
      Provider.of<EmailStore>(
        context,
        listen: false,
      ).bottomDrawerVisible = true;
      _drawerController.animateTo(0.4, curve: standardEasing);
      _dropArrowController.animateTo(0.35, curve: standardEasing);
      return;
    }

    _dropArrowController.forward();
    _drawerController.fling(
      velocity: _bottomDrawerVisible ? -_kFlingVelocity : _kFlingVelocity,
    );
  }

  double get _bottomDrawerHeight {
    final renderBox =
        _bottomDrawerKey.currentContext!.findRenderObject() as RenderBox;
    return renderBox.size.height;
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    _drawerController.value -= details.primaryDelta! / _bottomDrawerHeight;
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_drawerController.isAnimating ||
        _drawerController.status == AnimationStatus.completed) {
      return;
    }

    final flingVelocity =
        details.velocity.pixelsPerSecond.dy / _bottomDrawerHeight;

    if (flingVelocity < 0.0) {
      _drawerController.fling(
        velocity: math.max(_kFlingVelocity, -flingVelocity),
      );
    } else if (flingVelocity > 0.0) {
      _dropArrowController.forward();
      _drawerController.fling(
        velocity: math.min(-_kFlingVelocity, -flingVelocity),
      );
    } else {
      if (_drawerController.value < 0.6) {
        _dropArrowController.forward();
      }
      _drawerController.fling(
        velocity:
            _drawerController.value < 0.6 ? -_kFlingVelocity : _kFlingVelocity,
      );
    }
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification.depth == 0) {
      if (notification is UserScrollNotification) {
        switch (notification.direction) {
          case ScrollDirection.forward:
            _bottomAppBarController.forward();
            break;
          case ScrollDirection.reverse:
            _bottomAppBarController.reverse();
            break;
          case ScrollDirection.idle:
            break;
        }
      }
    }
    return false;
  }

  Widget _buildStack(BuildContext context, BoxConstraints constraints) {
    final drawerSize = constraints.biggest;
    final drawerTop = drawerSize.height;
    final ValueChanged<String> updateMailbox = _onDestinationSelected;

    final drawerAnimation = RelativeRectTween(
      begin: RelativeRect.fromLTRB(0.0, drawerTop, 0.0, 0.0),
      end: const RelativeRect.fromLTRB(0.0, 0.0, 0.0, 0.0),
    ).animate(_drawerCurve);

    return Stack(
      clipBehavior: Clip.none,
      key: _bottomDrawerKey,
      children: [
        NotificationListener<ScrollNotification>(
          onNotification: _handleScrollNotification,
          child: _MailRouter(
            drawerController: _drawerController,
          ),
        ),
        GestureDetector(
          onTap: () {
            _drawerController.reverse();
            _dropArrowController.reverse();
          },
          child: Visibility(
            maintainAnimation: true,
            maintainState: true,
            visible: _bottomDrawerVisible,
            child: FadeTransition(
              opacity: _drawerCurve,
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                color: Theme.of(context).bottomSheetTheme.modalBackgroundColor,
              ),
            ),
          ),
        ),
        PositionedTransition(
          rect: drawerAnimation,
          child: Visibility(
            visible: _bottomDrawerVisible,
            child: BottomDrawer(
              onVerticalDragUpdate: _handleDragUpdate,
              onVerticalDragEnd: _handleDragEnd,
              leading: _BottomDrawerDestinations(
                destinations: _navigationDestinations,
                drawerController: _drawerController,
                dropArrowController: _dropArrowController,
                onItemTapped: updateMailbox,
              ),
              trailing: _BottomDrawerFolderSection(folders: _folders),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: LayoutBuilder(
        builder: _buildStack,
      ),
      bottomNavigationBar: _AnimatedBottomAppBar(
        bottomAppBarController: _bottomAppBarController,
        bottomAppBarCurve: _bottomAppBarCurve,
        bottomDrawerVisible: _bottomDrawerVisible,
        drawerController: _drawerController,
        dropArrowCurve: _dropArrowCurve,
        toggleBottomDrawerVisibility: _toggleBottomDrawerVisibility,
      ),
      floatingActionButton: _bottomDrawerVisible
          ? null
          : const Padding(
              padding: EdgeInsetsDirectional.only(bottom: 8),
              child: _ReplyFab(),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class _AnimatedBottomAppBar extends StatelessWidget {
  const _AnimatedBottomAppBar({
    required this.bottomAppBarController,
    required this.bottomAppBarCurve,
    required this.bottomDrawerVisible,
    required this.drawerController,
    required this.dropArrowCurve,
    required this.toggleBottomDrawerVisibility,
  });

  final AnimationController bottomAppBarController;
  final Animation<double> bottomAppBarCurve;
  final bool bottomDrawerVisible;
  final AnimationController drawerController;
  final Animation<double> dropArrowCurve;
  final VoidCallback toggleBottomDrawerVisibility;

  @override
  Widget build(BuildContext context) {
    var fadeOut = Tween<double>(begin: 1, end: -1).animate(
      drawerController.drive(CurveTween(curve: standardEasing)),
    );

    return Selector<EmailStore, bool>(
      selector: (context, emailStore) => emailStore.onMailView,
      builder: (context, onMailView, child) {
        bottomAppBarController.forward();

        return SizeTransition(
          sizeFactor: bottomAppBarCurve,
          axisAlignment: -1,
          child: Padding(
            padding: const EdgeInsetsDirectional.only(top: 2),
            child: BottomAppBar(
              shape: const WaterfallNotchedRectangle(),
              notchMargin: 6,
              child: Container(
                color: Colors.transparent,
                height: kToolbarHeight,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      borderRadius: const BorderRadius.all(Radius.circular(16)),
                      onTap: toggleBottomDrawerVisibility,
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          RotationTransition(
                            turns: Tween(
                              begin: 0.0,
                              end: 1.0,
                            ).animate(dropArrowCurve),
                            child: const Icon(
                              Icons.arrow_drop_up,
                              color: ReplyColors.white50,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const _ReplyLogo(),
                          const SizedBox(width: 10),
                          _FadeThroughTransitionSwitcher(
                            fillColor: Colors.transparent,
                            child: onMailView
                                ? const SizedBox(width: 48)
                                : FadeTransition(
                                    opacity: fadeOut,
                                    child: Selector<EmailStore, String>(
                                      selector: (context, emailStore) =>
                                          emailStore.currentlySelectedInbox,
                                      builder: (
                                        context,
                                        currentlySelectedInbox,
                                        child,
                                      ) {
                                        return Text(
                                          currentlySelectedInbox,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge!
                                              .copyWith(
                                                color: ReplyColors.white50,
                                              ),
                                        );
                                      },
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        color: Colors.transparent,
                        child: _BottomAppBarActionItems(
                          drawerController: drawerController,
                          drawerVisible: bottomDrawerVisible,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BottomAppBarActionItems extends StatelessWidget {
  const _BottomAppBarActionItems({
    required this.drawerController,
    required this.drawerVisible,
  });

  final AnimationController drawerController;
  final bool drawerVisible;

  @override
  Widget build(BuildContext context) {
    return Consumer<EmailStore>(
      builder: (context, model, child) {
        final onMailView = model.onMailView;
        var radius = const Radius.circular(12);
        final modalBorder = BorderRadius.only(
          topRight: radius,
          topLeft: radius,
        );
        Color? starIconColor;

        if (onMailView) {
          var currentEmailStarred = false;

          if (model.emails[model.currentlySelectedInbox]!.isNotEmpty) {
            currentEmailStarred = model.isEmailStarred(
              model.emails[model.currentlySelectedInbox]!
                  .elementAt(model.currentlySelectedEmailId),
            );
          }

          starIconColor = currentEmailStarred
              ? Theme.of(context).colorScheme.secondary
              : ReplyColors.white50;
        }

        return _FadeThroughTransitionSwitcher(
          fillColor: Colors.transparent,
          child: drawerVisible
              ? Align(
                  key: UniqueKey(),
                  alignment: AlignmentDirectional.bottomEnd,
                  child: IconButton(
                    icon: const Icon(Icons.settings),
                    color: ReplyColors.white50,
                    onPressed: () async {
                      drawerController.reverse();
                      showModalBottomSheet(
                        context: context,
                        shape: RoundedRectangleBorder(
                          borderRadius: modalBorder,
                        ),
                        builder: (context) => const SettingsBottomSheet(),
                      );
                    },
                  ),
                )
              : onMailView
                  ? Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: ImageIcon(
                            const AssetImage(
                              '$_iconAssetLocation/twotone_star.png',
                              package: _assetsPackage,
                            ),
                            color: starIconColor,
                          ),
                          onPressed: () {
                            model.starEmail(
                              model.currentlySelectedInbox,
                              model.currentlySelectedEmailId,
                            );
                            if (model.currentlySelectedInbox == 'Starred') {
                              mobileMailNavKey.currentState!.pop();
                              model.currentlySelectedEmailId = -1;
                            }
                          },
                          color: ReplyColors.white50,
                        ),
                        IconButton(
                          icon: const ImageIcon(
                            AssetImage(
                              '$_iconAssetLocation/twotone_delete.png',
                              package: _assetsPackage,
                            ),
                          ),
                          onPressed: () {
                            model.deleteEmail(
                              model.currentlySelectedInbox,
                              model.currentlySelectedEmailId,
                            );

                            mobileMailNavKey.currentState!.pop();
                            model.currentlySelectedEmailId = -1;
                          },
                          color: ReplyColors.white50,
                        ),
                        IconButton(
                          icon: const Icon(Icons.more_vert),
                          onPressed: () {},
                          color: ReplyColors.white50,
                        ),
                      ],
                    )
                  : Align(
                      alignment: AlignmentDirectional.bottomEnd,
                      child: IconButton(
                        icon: const Icon(Icons.search),
                        color: ReplyColors.white50,
                        onPressed: () {
                          Provider.of<RouterProvider>(
                            context,
                            listen: false,
                          ).routePath = const ReplySearchPath();
                        },
                      ),
                    ),
        );
      },
    );
  }
}

class _BottomDrawerDestinations extends StatelessWidget {
  const _BottomDrawerDestinations({
    required this.destinations,
    required this.drawerController,
    required this.dropArrowController,
    required this.onItemTapped,
  });

  final List<_Destination> destinations;
  final AnimationController drawerController;
  final AnimationController dropArrowController;
  final ValueChanged<String> onItemTapped;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        for (var destination in destinations)
          InkWell(
            onTap: () {
              onItemTapped(destination.name);
              drawerController.reverse();
              dropArrowController.forward();
            },
            child: Selector<EmailStore, String>(
              selector: (context, emailStore) =>
                  emailStore.currentlySelectedInbox,
              builder: (context, currentlySelectedInbox, child) {
                return ListTile(
                  leading: ImageIcon(
                    AssetImage(
                      destination.icon,
                      package: _assetsPackage,
                    ),
                    color: destination.name == currentlySelectedInbox
                        ? theme.colorScheme.secondary
                        : ReplyColors.white50.withOpacity(0.64),
                  ),
                  title: Text(
                    destination.name,
                    style: theme.textTheme.bodyMedium!.copyWith(
                      color: destination.name == currentlySelectedInbox
                          ? theme.colorScheme.secondary
                          : ReplyColors.white50.withOpacity(0.64),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _Destination {
  const _Destination({
    required this.name,
    required this.icon,
    required this.index,
  });

  final String name;
  final String icon;
  final int index;
}

class _BottomDrawerFolderSection extends StatelessWidget {
  const _BottomDrawerFolderSection({required this.folders});

  final Map<String, String> folders;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        for (var folder in folders.keys)
          InkWell(
            onTap: () {},
            child: ListTile(
              leading: ImageIcon(
                AssetImage(
                  folders[folder]!,
                  package: _assetsPackage,
                ),
                color: ReplyColors.white50.withOpacity(0.64),
              ),
              title: Text(
                folder,
                style: theme.textTheme.bodyMedium!.copyWith(
                  color: ReplyColors.white50.withOpacity(0.64),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _MailRouter extends StatelessWidget {
  const _MailRouter({required this.drawerController});

  final AnimationController drawerController;

  @override
  Widget build(BuildContext context) {
    final RootBackButtonDispatcher backButtonDispatcher =
        Router.of(context).backButtonDispatcher as RootBackButtonDispatcher;

    return Router(
      routerDelegate:
          MailViewRouterDelegate(drawerController: drawerController),
      backButtonDispatcher: ChildBackButtonDispatcher(backButtonDispatcher)
        ..takePriority(),
    );
  }
}

class _ReplyLogo extends StatelessWidget {
  const _ReplyLogo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const ImageIcon(
      AssetImage(
        'reply/reply_logo.png',
        package: _assetsPackage,
      ),
      size: 32,
      color: ReplyColors.white50,
    );
  }
}

class _ReplyFab extends StatefulWidget {
  const _ReplyFab();

  @override
  _ReplyFabState createState() => _ReplyFabState();
}

class _ReplyFabState extends State<_ReplyFab>
    with SingleTickerProviderStateMixin {
  static final fabKey = UniqueKey();
  static const double _mobileFabDimension = 56;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const circleFabBorder = CircleBorder();

    return Selector<EmailStore, bool>(
      selector: (context, emailStore) => emailStore.onMailView,
      builder: (context, onMailView, child) {
        final fabSwitcher = _FadeThroughTransitionSwitcher(
          fillColor: Colors.transparent,
          child: onMailView
              ? Icon(
                  Icons.reply_all,
                  key: fabKey,
                  color: Colors.black,
                )
              : const Icon(
                  Icons.create,
                  color: Colors.black,
                ),
        );
        final tooltip = onMailView ? 'Reply' : 'Compose';

        return OpenContainer(
          openBuilder: (context, closedContainer) {
            return const ComposePage();
          },
          openColor: theme.cardColor,
          onClosed: (success) {
            Provider.of<EmailStore>(
              context,
              listen: false,
            ).onCompose = false;
          },
          closedShape: circleFabBorder,
          closedColor: theme.colorScheme.secondary,
          closedElevation: 6,
          closedBuilder: (context, openContainer) {
            return Tooltip(
              message: tooltip,
              child: InkWell(
                customBorder: circleFabBorder,
                onTap: () {
                  Provider.of<EmailStore>(
                    context,
                    listen: false,
                  ).onCompose = true;
                  openContainer();
                },
                child: SizedBox(
                  height: _mobileFabDimension,
                  width: _mobileFabDimension,
                  child: Center(
                    child: fabSwitcher,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _FadeThroughTransitionSwitcher extends StatelessWidget {
  const _FadeThroughTransitionSwitcher({
    required this.fillColor,
    required this.child,
  });

  final Widget child;
  final Color fillColor;

  @override
  Widget build(BuildContext context) {
    return PageTransitionSwitcher(
      transitionBuilder: (child, animation, secondaryAnimation) {
        return FadeThroughTransition(
          fillColor: fillColor,
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );
      },
      child: child,
    );
  }
}
