import 'dart:math' as math;

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'bottom_drawer.dart';
import 'colors.dart';
import 'compose_page.dart';
import 'inbox.dart';
import 'model/email_store.dart';
import 'search_page.dart';

const _assetsPackage = 'flutter_gallery_assets';
const _iconAssetLocation = 'reply/icons';
const _folderIconAssetLocation = '$_iconAssetLocation/twotone_folder.png';
final mobileMailNavKey = GlobalKey<NavigatorState>();
const double _kFlingVelocity = 2.0;
const _kAnimationDuration = Duration(milliseconds: 300);

class AdaptiveNav extends StatefulWidget {
  const AdaptiveNav({Key key}) : super(key: key);

  @override
  _AdaptiveNavState createState() => _AdaptiveNavState();
}

class _AdaptiveNavState extends State<AdaptiveNav> {
  int _selectedIndex = 0;

  Widget _currentInbox;
  UniqueKey _inboxKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _currentInbox = InboxPage(
      key: _inboxKey,
      destination: 'Inbox',
    );
  }

  @override
  Widget build(BuildContext context) {
    final _navigationDestinations = <_Destination>[
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

    return _MobileNav(
      selectedIndex: _selectedIndex,
      currentInbox: _currentInbox,
      destinations: _navigationDestinations,
      folders: _folders,
      onItemTapped: _onDestinationSelected,
    );
  }

  void _onDestinationSelected(int index, String destination) {
    var emailStore = Provider.of<EmailStore>(
      context,
      listen: false,
    );

    if (emailStore.currentlySelectedInbox != destination) {
      _inboxKey = UniqueKey();
    }

    emailStore.currentlySelectedInbox = destination;

    if (emailStore.onMailView) {
      mobileMailNavKey.currentState.pop();

      emailStore.currentlySelectedEmailId = -1;
    }

    setState(() {
      _selectedIndex = index;
      _currentInbox = InboxPage(
        key: _inboxKey,
        destination: destination,
      );
    });
  }
}

class _MobileNav extends StatefulWidget {
  const _MobileNav({
    this.selectedIndex,
    this.currentInbox,
    this.destinations,
    this.folders,
    this.onItemTapped,
  });

  final int selectedIndex;
  final Widget currentInbox;
  final List<_Destination> destinations;
  final Map<String, String> folders;
  final void Function(int, String) onItemTapped;

  @override
  _MobileNavState createState() => _MobileNavState();
}

class _MobileNavState extends State<_MobileNav> with TickerProviderStateMixin {
  final _bottomDrawerKey = GlobalKey(debugLabel: 'Bottom Drawer');
  AnimationController _drawerController;
  AnimationController _dropArrowController;
  AnimationController _bottomAppBarController;
  Animation<double> _drawerCurve;
  Animation<double> _dropArrowCurve;
  Animation<double> _bottomAppBarCurve;

  @override
  void initState() {
    super.initState();
    _drawerController = AnimationController(
      duration: _kAnimationDuration,
      value: 0,
      vsync: this,
    )..addListener(() {
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

  bool get _bottomDrawerVisible {
    final status = _drawerController.status;
    return status == AnimationStatus.completed ||
        status == AnimationStatus.forward;
  }

  void _toggleBottomDrawerVisibility() {
    if (_drawerController.value < 0.4) {
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
        _bottomDrawerKey.currentContext.findRenderObject() as RenderBox;
    return renderBox.size.height;
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    _drawerController.value -= details.primaryDelta / _bottomDrawerHeight;
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

    final drawerAnimation = RelativeRectTween(
      begin: RelativeRect.fromLTRB(0.0, drawerTop, 0.0, 0.0),
      end: const RelativeRect.fromLTRB(0.0, 0.0, 0.0, 0.0),
    ).animate(_drawerCurve);

    return Stack(
      overflow: Overflow.visible,
      key: _bottomDrawerKey,
      children: [
        NotificationListener<ScrollNotification>(
          onNotification: _handleScrollNotification,
          child: _MailNavigator(
            child: widget.currentInbox,
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
            child: AnimatedOpacity(
              opacity: _bottomDrawerVisible ? 1.0 : 0.0,
              curve: standardEasing,
              duration: _kAnimationDuration,
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
                destinations: widget.destinations,
                drawerController: _drawerController,
                dropArrowController: _dropArrowController,
                selectedIndex: widget.selectedIndex,
                onItemTapped: widget.onItemTapped,
              ),
              trailing: _BottomDrawerFolderSection(folders: widget.folders),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _SharedAxisTransitionSwitcher(
      defaultChild: Scaffold(
        extendBody: true,
        body: LayoutBuilder(
          builder: _buildStack,
        ),
        bottomNavigationBar: Selector<EmailStore, bool>(
          selector: (context, emailStore) => emailStore.onMailView,
          builder: (context, onMailView, child) {
            _bottomAppBarController.forward();

            return SizeTransition(
              sizeFactor: _bottomAppBarCurve,
              axisAlignment: -1,
              child: BottomAppBar(
                shape: const CircularNotchedRectangle(),
                notchMargin: 8,
                child: SizedBox(
                  height: kToolbarHeight,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(16)),
                        onTap: _toggleBottomDrawerVisibility,
                        child: Row(
                          children: [
                            const SizedBox(width: 16),
                            RotationTransition(
                              turns: Tween(
                                begin: 0.0,
                                end: 1.0,
                              ).animate(_dropArrowCurve),
                              child: const Icon(
                                Icons.arrow_drop_up,
                                color: ReplyColors.white50,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const _ReplyLogo(),
                            const SizedBox(width: 10),
                            AnimatedOpacity(
                              opacity: _bottomDrawerVisible || onMailView
                                  ? 0.0
                                  : 1.0,
                              duration: _kAnimationDuration,
                              curve: standardEasing,
                              child: Text(
                                widget.destinations[widget.selectedIndex].name,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1
                                    .copyWith(color: ReplyColors.white50),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
                          color: Colors.transparent,
                          child: _BottomAppBarActionItems(
                            drawerVisible: _bottomDrawerVisible,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        floatingActionButton: _bottomDrawerVisible
            ? null
            : const Padding(
                padding: EdgeInsetsDirectional.only(bottom: 8),
                child: _ReplyFab(),
              ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }
}

class _BottomAppBarActionItems extends StatelessWidget {
  const _BottomAppBarActionItems({@required this.drawerVisible})
      : assert(drawerVisible != null);

  final bool drawerVisible;

  @override
  Widget build(BuildContext context) {
    return Consumer<EmailStore>(
      builder: (context, model, child) {
        final onMailView = model.onMailView;
        Color starIconColor;

        if (onMailView) {
          var currentEmailStarred = false;

          if (model.emails[model.currentlySelectedInbox].isNotEmpty) {
            currentEmailStarred = model.isEmailStarred(
              model.emails[model.currentlySelectedInbox]
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
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(Icons.settings),
                    color: ReplyColors.white50,
                    onPressed: () {},
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
                              mobileMailNavKey.currentState.pop();
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

                            mobileMailNavKey.currentState.pop();
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
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: const Icon(Icons.search),
                        color: ReplyColors.white50,
                        onPressed: () {
                          Provider.of<EmailStore>(
                            context,
                            listen: false,
                          ).onSearchPage = true;
                        },
                      ),
                    ),
        );
      },
    );
  }
}

class _BottomDrawerDestinations extends StatelessWidget {
  _BottomDrawerDestinations({
    @required this.destinations,
    @required this.drawerController,
    @required this.dropArrowController,
    @required this.selectedIndex,
    @required this.onItemTapped,
  })  : assert(destinations != null),
        assert(drawerController != null),
        assert(dropArrowController != null),
        assert(selectedIndex != null),
        assert(onItemTapped != null);

  final List<_Destination> destinations;
  final AnimationController drawerController;
  final AnimationController dropArrowController;
  final int selectedIndex;
  final void Function(int, String) onItemTapped;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        for (var destination in destinations)
          InkWell(
            onTap: () {
              drawerController.reverse();
              dropArrowController.forward();
              Future.delayed(
                Duration(milliseconds: drawerController.value == 1 ? 300 : 120),
                () {
                  // Wait until animations are complete to reload the state.
                  // Delay scales with the timeDilation value of the gallery.
                  onItemTapped(destination.index, destination.name);
                },
              );
            },
            child: ListTile(
              leading: ImageIcon(
                AssetImage(
                  destination.icon,
                  package: _assetsPackage,
                ),
                color: destination.index == selectedIndex
                    ? theme.colorScheme.secondary
                    : theme.navigationRailTheme.unselectedLabelTextStyle.color,
              ),
              title: Text(
                destination.name,
                style: theme.textTheme.bodyText2.copyWith(
                  color: destination.index == selectedIndex
                      ? theme.colorScheme.secondary
                      : theme
                          .navigationRailTheme.unselectedLabelTextStyle.color,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _Destination {
  const _Destination({
    @required this.name,
    @required this.icon,
    @required this.index,
  })  : assert(name != null),
        assert(icon != null),
        assert(index != null);

  final String name;
  final String icon;
  final int index;
}

class _BottomDrawerFolderSection extends StatelessWidget {
  const _BottomDrawerFolderSection({@required this.folders})
      : assert(folders != null);

  final Map<String, String> folders;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final navigationRailTheme = theme.navigationRailTheme;

    return Column(
      children: [
        for (var folder in folders.keys)
          InkWell(
            onTap: () {},
            child: ListTile(
              leading: ImageIcon(
                AssetImage(
                  folders[folder],
                  package: _assetsPackage,
                ),
                color: navigationRailTheme.unselectedLabelTextStyle.color,
              ),
              title: Text(
                folder,
                style: theme.textTheme.bodyText2.copyWith(
                  color: navigationRailTheme.unselectedLabelTextStyle.color,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _MailNavigator extends StatefulWidget {
  const _MailNavigator({@required this.child}) : assert(child != null);

  final Widget child;

  @override
  _MailNavigatorState createState() => _MailNavigatorState();
}

class _MailNavigatorState extends State<_MailNavigator> {
  static const inboxRoute = '/reply/inbox';

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: mobileMailNavKey,
      initialRoute: inboxRoute,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case inboxRoute:
            return MaterialPageRoute<void>(
              builder: (context) {
                return _FadeThroughTransitionSwitcher(
                  fillColor: Theme.of(context).scaffoldBackgroundColor,
                  child: widget.child,
                );
              },
              settings: settings,
            );
            break;
          case ReplyApp.composeRoute:
            return ReplyApp.createComposeRoute(settings);
            break;
        }
        return null;
      },
    );
  }
}

class _ReplyLogo extends StatelessWidget {
  const _ReplyLogo({Key key}) : super(key: key);

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
  const _ReplyFab({this.extended = false});

  final bool extended;

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
    final circleFabBorder = const CircleBorder();

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
          closedShape: circleFabBorder,
          closedColor: theme.colorScheme.secondary,
          closedElevation: 6,
          closedBuilder: (context, openContainer) {
            return Tooltip(
              message: tooltip,
              child: InkWell(
                customBorder: circleFabBorder,
                onTap: openContainer,
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
    @required this.fillColor,
    @required this.child,
  })  : assert(fillColor != null),
        assert(child != null);

  final Widget child;
  final Color fillColor;

  @override
  Widget build(BuildContext context) {
    return PageTransitionSwitcher(
      transitionBuilder: (child, animation, secondaryAnimation) {
        return FadeThroughTransition(
          fillColor: fillColor,
          child: child,
          animation: animation,
          secondaryAnimation: secondaryAnimation,
        );
      },
      child: child,
    );
  }
}

class _SharedAxisTransitionSwitcher extends StatelessWidget {
  const _SharedAxisTransitionSwitcher({
    @required this.defaultChild,
  }) : assert(defaultChild != null);

  final Widget defaultChild;

  @override
  Widget build(BuildContext context) {
    return Selector<EmailStore, bool>(
      selector: (context, emailStore) => emailStore.onSearchPage,
      builder: (context, onSearchPage, child) {
        return PageTransitionSwitcher(
          reverse: !onSearchPage,
          transitionBuilder: (child, animation, secondaryAnimation) {
            return SharedAxisTransition(
              fillColor: Theme.of(context).cardColor,
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              transitionType: SharedAxisTransitionType.scaled,
              child: child,
            );
          },
          child: onSearchPage ? const SearchPage() : defaultChild,
        );
      },
    );
  }
}
