import 'package:flutter/material.dart';
import 'package:park_ui/park_ui.dart';

// =============================================================================
// NavBar Demo
// =============================================================================

class NavBarDemo extends StatelessWidget {
  const NavBarDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('NavBar 导航栏', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('顶部导航栏，支持标题、返回箭头和右侧操作。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('基础用法', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const ParkNavBar(
            title: Text('标题'),
            leftArrow: true,
          ),
        ),
        const SizedBox(height: 24),

        ParkText('带右侧操作', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ParkNavBar(
            title: const Text('消息'),
            leftArrow: true,
            rightActions: [
              IconButton(
                icon: const Icon(Icons.search, size: 20),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.more_horiz, size: 20),
                onPressed: () {},
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        ParkText('带副标题', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const ParkNavBar(
            title: Text('主页'),
            subTitle: '欢迎回来',
            leftArrow: true,
          ),
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}

// =============================================================================
// Steps Demo
// =============================================================================

class StepsDemo extends StatefulWidget {
  const StepsDemo({super.key});

  @override
  State<StepsDemo> createState() => _StepsDemoState();
}

class _StepsDemoState extends State<StepsDemo> {
  int _currentStep = 1;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('Steps 步骤条', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('展示任务进度，显示每个步骤的状态。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('水平步骤条', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkSteps(
          steps: const [
            ParkStep(title: '基本信息'),
            ParkStep(title: '详细配置', description: '填写详细资料'),
            ParkStep(title: '完成'),
          ],
          currentStep: _currentStep,
        ),
        const SizedBox(height: 12),
        ParkSpace(
          size: 8,
          children: [
            ParkButton(
              variant: ParkButtonVariant.secondary,
              onPressed: _currentStep > 0
                  ? () => setState(() => _currentStep--)
                  : null,
              child: const Text('上一步'),
            ),
            ParkButton(
              variant: ParkButtonVariant.primary,
              onPressed: _currentStep < 2
                  ? () => setState(() => _currentStep++)
                  : null,
              child: const Text('下一步'),
            ),
          ],
        ),
        const SizedBox(height: 24),

        ParkText('垂直步骤条', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkSteps(
          steps: const [
            ParkStep(title: '等待付款', description: '订单已创建'),
            ParkStep(title: '正在配送', description: '快递员已取件'),
            ParkStep(title: '已签收', description: '包裹已送达'),
          ],
          currentStep: 1,
          direction: ParkStepsDirection.vertical,
        ),
        const SizedBox(height: 24),

        ParkText('错误状态', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkSteps(
          steps: const [
            ParkStep(title: '上传文件'),
            ParkStep(title: '校验数据', status: ParkStepStatus.error),
            ParkStep(title: '提交成功'),
          ],
          currentStep: 1,
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}

// =============================================================================
// BackTop Demo
// =============================================================================

class BackTopDemo extends StatelessWidget {
  const BackTopDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('BackTop 回到顶部', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('滚动超过阈值时显示回到顶部按钮。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('示例', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        SizedBox(
          height: 300,
          child: Stack(
            children: [
              ListView.builder(
                controller: scrollController,
                itemCount: 50,
                itemBuilder: (_, i) => ListTile(
                  title: Text('列表项 $i'),
                  dense: true,
                ),
              ),
              ParkBackTop(
                scrollController: scrollController,
                visibleOffset: 100,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}

// =============================================================================
// Indexes Demo
// =============================================================================

class IndexesDemo extends StatelessWidget {
  const IndexesDemo({super.key});

  static const List<String> _letters = [
    'A', 'B', 'C', 'D', 'E', 'F', 'G',
    'H', 'I', 'J', 'K', 'L', 'M',
    'N', 'O', 'P', 'Q', 'R', 'S',
    'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('Indexes 字母索引', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('列表右侧字母索引条，常用于通讯录等场景。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('基础用法', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        SizedBox(
          height: 400,
          child: Row(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: _letters.length,
                  itemBuilder: (_, i) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                      child: Text(
                        '${_letters[i]} - 分组内容',
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  },
                ),
              ),
              ParkIndexes(
                indexes: _letters,
                onIndexSelected: (index) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('选中索引: $index'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}
