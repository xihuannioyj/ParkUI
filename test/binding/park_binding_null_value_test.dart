import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/src/binding/park_binding_service.dart';

void main() {
  group('ParkBindingService 空模型绑定（回归：登录页崩溃）', () {
    test('空模型 bind<String> 不崩，返回空字符串', () {
      final service = ParkBindingService();
      final bindable = service.bind<String>('username');
      expect(bindable.value, '');
    });

    test('模型含 null 值 bind<String> 不崩', () {
      final service = ParkBindingService({'username': null});
      final bindable = service.bind<String>('username');
      expect(bindable.value, '');
    });

    test('bind<int> 空模型返回 0', () {
      final service = ParkBindingService();
      expect(service.bind<int>('age').value, 0);
    });

    test('bind<double> 空模型返回 0.0', () {
      final service = ParkBindingService();
      expect(service.bind<double>('price').value, 0.0);
    });

    test('bind<bool> 空模型返回 false', () {
      final service = ParkBindingService();
      expect(service.bind<bool>('remember').value, false);
    });

    test('bind<String> 模型有值时返回模型值', () {
      final service = ParkBindingService({'username': 'admin'});
      expect(service.bind<String>('username').value, 'admin');
    });

    test('bind<String> 模型值为数字时 toString 转换', () {
      final service = ParkBindingService({'username': 12345});
      expect(service.bind<String>('username').value, '12345');
    });

    test('bind<String> 显式 defaultValue 优先', () {
      final service = ParkBindingService();
      expect(service.bind<String>('username', defaultValue: 'guest').value, 'guest');
    });

    test('空模型后 setValue 再 bind 其它路径互不影响', () {
      final service = ParkBindingService();
      final u = service.bind<String>('username');
      u.value = '张三';
      final p = service.bind<String>('password');
      expect(p.value, '');
      expect(service.getValue<String>('username'), '张三');
    });

    test('嵌套路径缺省 bind<String> 不崩', () {
      final service = ParkBindingService({'user': {'name': '李四'}});
      expect(service.bind<String>('user.name').value, '李四');
      expect(service.bind<String>('user.phone').value, '');
    });
  });
}
