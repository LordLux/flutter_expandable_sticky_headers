import 'package:flutter/material.dart';
import 'package:sticky_headers/sticky_headers.dart';

import './images.dart';

void main() => runApp(const ExampleApp());

@immutable
class ExampleApp extends StatelessWidget {
  const ExampleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sticky Headers Example',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: Example2(),
    );
  }
}
@immutable
class Example2 extends StatelessWidget {
  const Example2({
    super.key,
    this.controller,
  });

  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      wrap: controller == null,
      title: 'Example',
      child: ListView.builder(
        primary: controller == null,
        controller: controller,
        itemBuilder: (context, index) {
          return ExpandingStickyHeaderBuilder(
            controller: controller, // Optional
            builder: (BuildContext context, double stuckAmount, bool isHovering) {
              stuckAmount = 1.0 - stuckAmount.clamp(0.0, 1.0);
              return Container(
                height: 50.0,
                color: Color.lerp(Colors.blue[700], Colors.red[700], stuckAmount),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                alignment: Alignment.centerLeft,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Header #$index',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    Offstage(
                      offstage: stuckAmount <= 0.0,
                      child: Opacity(
                        opacity: stuckAmount,
                        child: IconButton(
                          icon: const Icon(Icons.favorite, color: Colors.white),
                          onPressed: () => ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text('Favorite #$index'))),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            content: Container(
              color: Colors.grey[300],
              child: Image.network(
                imageForIndex(index),
                fit: BoxFit.cover,
                width: double.infinity,
                height: 200.0,
              ),
            ),
          );
        },
      ),
    );
  }

  String imageForIndex(int index) {
    return Images.imageThumbUrls[index % Images.imageThumbUrls.length];
  }
}

@immutable
class ScaffoldWrapper extends StatelessWidget {
  const ScaffoldWrapper({
    Key? key,
    required this.title,
    required this.child,
    this.wrap = true,
  }) : super(key: key);

  final Widget child;
  final String title;
  final bool wrap;

  @override
  Widget build(BuildContext context) {
    if (wrap) {
      return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Hero(
            tag: 'app_bar',
            child: AppBar(
              title: Text(title),
              elevation: 0.0,
            ),
          ),
        ),
        body: child,
      );
    } else {
      return Material(
        child: child,
      );
    }
  }
}

@immutable
class Example4 extends StatefulWidget {
  const Example4({Key? key}) : super(key: key);

  @override
  State<Example4> createState() => _Example4State();
}

class _Example4State extends State<Example4> {
  late final _controller = List.generate(4, (_) => ScrollController());

  @override
  Widget build(BuildContext context) {
    return Material(
      child: DefaultTabController(
        length: 3,
        child: NestedScrollView(
          controller: _controller[0],
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                title: const Text('Example 4'),
                pinned: true,
                forceElevated: innerBoxIsScrolled,
                bottom: const TabBar(
                  tabs: <Tab>[
                    Tab(text: 'Example 1'),
                    Tab(text: 'Example 2'),
                    Tab(text: 'Example 3'),
                  ],
                ),
              ),
            ];
          },
          body: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: TabBarView(
              children: <Widget>[
                Example2(controller: _controller[2]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
