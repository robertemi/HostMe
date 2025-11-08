import 'package:flutter/material.dart';

class ActivitySection extends StatelessWidget {
  const ActivitySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Activity',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        _Tabs(),
        const SizedBox(height: 12),
        const _MatchesGrid(),
      ],
    );
  }
}

class _Tabs extends StatefulWidget {
  @override
  State<_Tabs> createState() => _TabsState();
}

class _TabsState extends State<_Tabs> {
  int index = 0; // 0 Matches, 1 Past Swipes, 2 Liked You (static content)
  @override
  Widget build(BuildContext context) {
    final labels = ['Matches', 'Past Swipes', 'Liked You'];
    return Row(
      children: [
        for (int i = 0; i < labels.length; i++)
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => index = i),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: i == index
                          ? Theme.of(context).primaryColor
                          : Colors.white24,
                      width: 2,
                    ),
                  ),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      labels[i],
                      style: TextStyle(
                        color: i == index ? Theme.of(context).primaryColor : Colors.white70,
                        fontWeight: i == index ? FontWeight.w800 : FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    if (i == 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text('3', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
                      ),
                    ]
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _MatchesGrid extends StatelessWidget {
  const _MatchesGrid();
  @override
  Widget build(BuildContext context) {
    final items = [
      _GridItem('Sarah, 21', 'https://i.pravatar.cc/300?img=5'),
      _GridItem('Mike, 23', 'https://i.pravatar.cc/300?img=6'),
      _GridItem('Emily, 20', 'https://i.pravatar.cc/300?img=7'),
      _GridItem('Unlock More', 'https://i.pravatar.cc/300?img=8', locked: true),
    ];
    final crossAxisCount = MediaQuery.of(context).size.width > 600 ? 4 : 2;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemBuilder: (context, i) => _GridTile(item: items[i]),
    );
  }
}

class _GridItem {
  final String label;
  final String url;
  final bool locked;
  _GridItem(this.label, this.url, {this.locked = false});
}

class _GridTile extends StatelessWidget {
  const _GridTile({required this.item});
  final _GridItem item;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(item.url, fit: BoxFit.cover),
                if (item.locked)
                  Container(
                    color: Colors.black.withOpacity(0.4),
                    child: const Center(
                      child: Icon(Icons.lock, color: Colors.white, size: 36),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          item.label,
          style: TextStyle(
            color: item.locked ? Colors.white70 : Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
