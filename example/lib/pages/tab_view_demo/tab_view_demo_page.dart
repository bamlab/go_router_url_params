import 'package:example/pages/tab_view_demo/flavor.dart';
import 'package:flutter/material.dart';
import 'package:go_router_url_params/go_router_url_params.dart';

class TabViewDemoPage extends StatefulWidget {
  const TabViewDemoPage({super.key});

  @override
  State<TabViewDemoPage> createState() => _TabViewDemoPageState();
}

class _TabViewDemoPageState extends State<TabViewDemoPage>
    with TickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: Flavor.values.length, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // When the tab changes, update the flavor in the url
      tabController.addListener(() {
        final newFlavor = Flavor.values[tabController.index];
        Flavor.setInUrl(context, newFlavor);
      });
    });
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final flavor = Flavor.watchFromUrl(context);
    if (flavor == null) {
      return const NoValidFlavorFound();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // When the flavor changes in the url, update the tab
      if (tabController.index != flavor.index) {
        tabController.animateTo(
          flavor.index,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(context.uri.toString())),
      body: Center(
        child: Column(
          children: [
            TabBar(
              controller: tabController,
              tabs: [
                for (final flavor in Flavor.values) Tab(text: flavor.name),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: tabController,
                children: [for (final _ in Flavor.values) _FlavorContent()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FlavorContent extends StatelessWidget {
  const _FlavorContent();

  @override
  Widget build(BuildContext context) {
    // You can also get the pathParam lower in the widget tree without any props drilling
    final flavor = Flavor.watchFromUrl(context) ?? Flavor.defaultFlavor;
    return Center(child: Text('I love ${flavor.name}'));
  }
}

class NoValidFlavorFound extends StatelessWidget {
  const NoValidFlavorFound({super.key});

  @override
  Widget build(BuildContext context) {
    // When you can't parse the param, you can still easily get the raw value
    final invalidFlavor = context.watchPathParamFromKey<String>('flavor');
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'No valid flavor found in url. Invalid flavor: $invalidFlavor',
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Flavor.setInUrl(context, Flavor.defaultFlavor);
              },
              child: Text('Go to default flavor'),
            ),
          ],
        ),
      ),
    );
  }
}
