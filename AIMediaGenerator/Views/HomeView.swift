import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // Фоновое свечение сверху
            GradientBackgroundView()
            
            VStack(spacing: 0) {
                //  Кнопка шестерёнки справа вверху
                HStack {
                    Spacer()
                    Button(action: { viewModel.openSettings() }) {
                        Image(systemName: "gearshape")
                            .font(.system(size: 22))
                            .foregroundColor(.white.opacity(0.4))
                            .padding(10)
                            .background(Color.white.opacity(0.05))
                            .clipShape(Circle())
                    }
                    .padding(.trailing, 16)
                }
                .padding(.top, 16)
                
                // Иконка + Заголовок
                VStack(spacing: 24) {
                    viewModel.brandGradient
                        .mask(
                            Image("Icons/icon/Generate B")
                                .resizable()
                                .scaledToFit()
                        )
                        .frame(width: 64, height: 64)
                    
                    Text("Your AI tools,\nready to go")
                        .font(.custom("Inter-Bold", size: 34))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                .padding(.top, 24)
                
                // Ask anything...
                Button(action: { viewModel.startSearch() }) {
                    HStack(spacing: 12) {
                        Image("Icons/icon/Generate B-1")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.7))
                        
                        Text("Ask anything...")
                            .font(.custom("Inter-Regular", size: 16))
                            .foregroundColor(.white.opacity(0.3))
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 54)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(27)
                    .overlay(
                        RoundedRectangle(cornerRadius: 27)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
                }
                .padding(.horizontal, 16)
                .padding(.top, 32)
                
                // Контентная зона с карточкой
                // TODO: - Не забыть и добавить карточки справа
                HStack(alignment: .top, spacing: 12) {
                    // Большая карточка "Turn Photo into Video"
                    Button(action: { viewModel.openPhotoToVideo() }) {
                        VStack(alignment: .leading, spacing: 0) {
                            // Иконка в кружочке сверху карточки
                            Image("Icons/icon/Image to image")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                                .frame(width: 36, height: 36)
                                .background(Color.white.opacity(0.15))
                                .clipShape(Circle())
                                .padding(.top, 20)
                                .padding(.leading, 16)
                            
                            // Заголовки карточки
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Turn Photo\ninto Video")
                                    .font(.custom("Inter-Bold", size: 22))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.leading)
                                    .lineSpacing(2)
                                
                                Text("Animate • Templates")
                                    .font(.custom("Inter-Medium", size: 14))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            .padding(.top, 24)
                            .padding(.leading, 16)
                            
                            Spacer()
                            
                            // Нижняя кнопка (ready...)
                            HStack(spacing: 6) {
                                Text("Ready in seconds")
                                    .font(.custom("Inter-Medium", size: 12))
                                    .foregroundColor(.white)
                                
                                Image(systemName: "play.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(15)
                            .padding(.leading, 16)
                            .padding(.bottom, 20)
                        }
                        .frame(width: 190, height: 280)
                        .background(viewModel.brandGradient)
                        .cornerRadius(24)
                    }
                    
                    // Правая колонка с двумя маленькими карточками
                    VStack(spacing: 12) {
                        // Карточка 1 (справа-вверху)
                        Button(action: { viewModel.openFixAndImprove() }) {
                            VStack(alignment: .leading, spacing: 0) {
                                viewModel.brandGradient
                                    .mask(
                                        Image("Icons/icon/Magic pencil A")
                                            .resizable()
                                            .scaledToFit()
                                            .padding(6) // Серое пространство
                                    )
                                    .frame(width: 32, height: 32)
                                    .background(Color.white.opacity(0.08))
                                    .clipShape(Circle())
                                    .padding(.top, 14)
                                    .padding(.leading, 14)
                                
                                Spacer()
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Fix & Improve\nWriting")
                                        .font(.custom("Inter-Bold", size: 16))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.leading)
                                    
                                    Text("Rewrite • Fix grammar")
                                        .font(.custom("Inter-Medium", size: 12))
                                        .foregroundColor(.white.opacity(0.4))
                                }
                                .padding(.leading, 14)
                                .padding(.bottom, 14)
                            }
                            .frame(maxWidth: .infinity, minHeight: 134, maxHeight: 134)
                            .background(Color.white.opacity(0.04))
                            .cornerRadius(20)
                        }
                        
                        // Карточка 2 (справа-внизу)
                        Button(action: { viewModel.openUnderstandFaster() }) {
                            VStack(alignment: .leading, spacing: 0) {
                                viewModel.brandGradient
                                    .mask(
                                        Image("Icons/icon/prompt A")
                                            .resizable()
                                            .scaledToFit()
                                            .padding(6) // Серое пространство
                                    )
                                    .frame(width: 32, height: 32)
                                    .background(Color.white.opacity(0.08))
                                    .clipShape(Circle())
                                    .padding(.top, 14)
                                    .padding(.leading, 14)
                                
                                Spacer()
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Understand\nFaster")
                                        .font(.custom("Inter-Bold", size: 16))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.leading)
                                    
                                    Text("Summarize • Key points")
                                        .font(.custom("Inter-Medium", size: 12))
                                        .foregroundColor(.white.opacity(0.4))
                                }
                                .padding(.leading, 14)
                                .padding(.bottom, 14)
                            }
                            .frame(maxWidth: .infinity, minHeight: 134, maxHeight: 134)
                            .background(Color.white.opacity(0.04))
                            .cornerRadius(20)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 32)
                Spacer()
            }
        }
        .fullScreenCover(item: $viewModel.activeDestination) { destination in
            switch destination {
            case .chat:
                ChatView()
            case .paywall:
                PaywallView()
            case .videoList:
                VideoListView()
            }
        }
    }
}

#Preview {
    HomeView()
}
