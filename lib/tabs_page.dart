import 'package:flutter/material.dart';
import 'package:firebase_analytics/observer.dart';

class TabsPage extends StatefulWidget {
  const TabsPage(this.observer, {Key? key}) : super(key: key);

  final FirebaseAnalyticsObserver observer;

  static const String routeName = '/tab';

  @override
  State<StatefulWidget> createState() => _TabsPageState();
}

class _TabsPageState extends State<TabsPage> with SingleTickerProviderStateMixin, RouteAware {

  late final TabController _controller = TabController(
    vsync: this,
    length: tabs.length,
    initialIndex: selectedIndex,
  );
  int selectedIndex = 0;

  final List<Tab> tabs = <Tab>[
    const Tab(text: 'Tela 1'),
    const Tab(text: 'Tela 2'),
    const Tab(text: 'Tela 3'),
    const Tab(text: 'Tela 4'),
    const Tab(text: 'Tela 5'),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.observer.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void dispose() {
    widget.observer.unsubscribe(this);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        if (selectedIndex != _controller.index) {
          selectedIndex = _controller.index;
          _sendCurrentTabToAnalytics();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firebase Analytics'),
        bottom: TabBar(
          controller: _controller,
          tabs: tabs,
        ),
      ),
      body: TabBarView(
        controller: _controller,
        children: tabs.map((Tab tab) {
          return Center(child: ElevatedButton(
            child: Text('Precione o Botão'),
            onPressed: (){
            _showDialog(tab.text!);
            }
          ));
        }).toList(),
      ),
    );
  }

  void _showDialog(String tab) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(tab),
          actions: <Widget>[
            new TextButton(
              child: new Text("Fechar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void didPush() {
    _sendCurrentTabToAnalytics();
  }

  @override
  void didPopNext() {
    _sendCurrentTabToAnalytics();
  }

  void _sendCurrentTabToAnalytics() {
    widget.observer.analytics.setCurrentScreen(
      screenName: '${TabsPage.routeName}/tab$selectedIndex',
    );
  }
}