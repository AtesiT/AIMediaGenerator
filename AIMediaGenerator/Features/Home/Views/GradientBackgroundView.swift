import SwiftUI

struct GradientBackgroundView: View {

    private let brandGradient = LinearGradient(
        colors: [
            Color(red: 0.596, green: 0.776, blue: 0.969), // #98C6F7
            Color(red: 0.922, green: 0.357, blue: 0.573)  // #EB5B92
        ],
        startPoint: .leading,
        endPoint: .trailing
    )

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height

                ZStack {
                    // Большой градиентный эллипс (без изменений)
                    Ellipse()
                        .fill(brandGradient.opacity(0.6))
                        .frame(width: w * 1.3, height: h * 0.38)
                        .rotationEffect(.degrees(-15))
                        .offset(x: -w * 0.15, y: -h * 0.18)
                        .blur(radius: 60)

                    // Чёрный эллипс слева (здесь вносим точечные правки)
                    Ellipse()
                        .fill(Color.black)
                        // ИЗМЕНЕНИЕ 1: Слегка увеличиваем высоту для надежности
                        .frame(width: w * 1.1, height: h * 0.5) // Было 0.45
                        // ИЗМЕНЕНИЕ 2: Самое главное - смещаем эллипс НИЖЕ, чтобы он закрыл синий край
                        .offset(x: -w * 0.25, y: h * 0.05) // Было 0.02
                        .blur(radius: 60)

                    // Чёрный эллипс справа (без изменений)
                    Ellipse()
                        .fill(Color.black)
                        .frame(width: w * 0.85, height: h * 0.32)
                        .offset(x: w * 0.3, y: h * 0.1)
                        .blur(radius: 60)
                }
                .frame(width: w, height: h, alignment: .topLeading)
                .offset(y: h * 0.1)
            }
            .ignoresSafeArea()
        }
    }
}

#Preview {
    GradientBackgroundView()
}
