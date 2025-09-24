//
//  ContentView.swift
//  TH75
//
//  Created by IGOR on 18/09/2025.
//

import SwiftUI
import Foundation

// MARK: - Data Models
enum TaskPriority: String, CaseIterable, Codable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case urgent = "Urgent"
    
    var color: Color {
        switch self {
        case .low: return Color.gray
        case .medium: return AppTheme.accent
        case .high: return Color.orange
        case .urgent: return AppTheme.secondaryButton
        }
    }
    
    var icon: String {
        switch self {
        case .low: return "arrow.down.circle"
        case .medium: return "minus.circle"
        case .high: return "arrow.up.circle"
        case .urgent: return "exclamationmark.triangle.fill"
        }
    }
}

enum TaskCategory: String, CaseIterable, Codable {
    case work = "Work"
    case personal = "Personal"
    case health = "Health"
    case learning = "Learning"
    case shopping = "Shopping"
    case finance = "Finance"
    case travel = "Travel"
    case home = "Home"
    
    var color: Color {
        switch self {
        case .work: return Color.blue
        case .personal: return AppTheme.primaryButton
        case .health: return Color.red
        case .learning: return Color.purple
        case .shopping: return Color.orange
        case .finance: return Color.green
        case .travel: return Color.cyan
        case .home: return Color.brown
        }
    }
    
    var icon: String {
        switch self {
        case .work: return "briefcase.fill"
        case .personal: return "person.fill"
        case .health: return "heart.fill"
        case .learning: return "book.fill"
        case .shopping: return "cart.fill"
        case .finance: return "dollarsign.circle.fill"
        case .travel: return "airplane"
        case .home: return "house.fill"
        }
    }
}

struct Task: Identifiable, Codable {
    let id = UUID()
    var title: String
    var notes: String
    var isCompleted: Bool = false
    var priority: TaskPriority
    var category: TaskCategory
    var dueDate: Date?
    var createdAt: Date = Date()
    var completedAt: Date?
    var estimatedDuration: Int // in minutes
    
    enum CodingKeys: String, CodingKey {
        case title, notes, isCompleted, priority, category, dueDate, createdAt, completedAt, estimatedDuration
    }
    
    init(title: String, notes: String = "", priority: TaskPriority = .medium, category: TaskCategory = .personal, dueDate: Date? = nil, estimatedDuration: Int = 30) {
        self.title = title
        self.notes = notes
        self.priority = priority
        self.category = category
        self.dueDate = dueDate
        self.estimatedDuration = estimatedDuration
        self.isCompleted = false
        self.createdAt = Date()
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        notes = try container.decodeIfPresent(String.self, forKey: .notes) ?? ""
        isCompleted = try container.decode(Bool.self, forKey: .isCompleted)
        priority = try container.decodeIfPresent(TaskPriority.self, forKey: .priority) ?? .medium
        category = try container.decodeIfPresent(TaskCategory.self, forKey: .category) ?? .personal
        dueDate = try container.decodeIfPresent(Date.self, forKey: .dueDate)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        completedAt = try container.decodeIfPresent(Date.self, forKey: .completedAt)
        estimatedDuration = try container.decodeIfPresent(Int.self, forKey: .estimatedDuration) ?? 30
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(notes, forKey: .notes)
        try container.encode(isCompleted, forKey: .isCompleted)
        try container.encode(priority, forKey: .priority)
        try container.encode(category, forKey: .category)
        try container.encodeIfPresent(dueDate, forKey: .dueDate)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encodeIfPresent(completedAt, forKey: .completedAt)
        try container.encode(estimatedDuration, forKey: .estimatedDuration)
    }
    
    var isOverdue: Bool {
        guard let dueDate = dueDate, !isCompleted else { return false }
        return Date() > dueDate
    }
    
    var dueDateText: String {
        guard let dueDate = dueDate else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: dueDate)
    }
    
    var estimatedDurationText: String {
        if estimatedDuration < 60 {
            return "\(estimatedDuration)m"
        } else {
            let hours = estimatedDuration / 60
            let minutes = estimatedDuration % 60
            if minutes == 0 {
                return "\(hours)h"
            } else {
                return "\(hours)h \(minutes)m"
            }
        }
    }
}

struct FocusSession: Identifiable, Codable {
    let id = UUID()
    var duration: TimeInterval
    var completedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case duration, completedAt
    }
    
    init(duration: TimeInterval, completedAt: Date) {
        self.duration = duration
        self.completedAt = completedAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        duration = try container.decode(TimeInterval.self, forKey: .duration)
        completedAt = try container.decode(Date.self, forKey: .completedAt)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(duration, forKey: .duration)
        try container.encode(completedAt, forKey: .completedAt)
    }
}

enum Badge: String, CaseIterable, Codable {
    case bronze = "Bronze Focus"
    case silver = "Silver Focus"
    case gold = "Gold Focus"
    case platinum = "Platinum Focus"
    
    var icon: String {
        switch self {
        case .bronze: return "medal.fill"
        case .silver: return "medal.fill"
        case .gold: return "medal.fill"
        case .platinum: return "crown.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .bronze: return Color(hex: "CD7F32")
        case .silver: return Color(hex: "C0C0C0")
        case .gold: return Color(hex: "FFD700")
        case .platinum: return Color(hex: "E5E4E2")
        }
    }
    
    var requirement: Int {
        switch self {
        case .bronze: return 5
        case .silver: return 15
        case .gold: return 30
        case .platinum: return 50
        }
    }
}

// MARK: - App State Manager
class AppStateManager: ObservableObject {
    @Published var hasCompletedOnboarding: Bool = false
    @Published var tasks: [Task] = []
    @Published var focusSessions: [FocusSession] = []
    @Published var earnedBadges: Set<Badge> = []
    
    init() {
        loadData()
    }
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
        saveData()
    }
    
    func addTask(_ title: String, notes: String = "", priority: TaskPriority = .medium, category: TaskCategory = .personal, dueDate: Date? = nil, estimatedDuration: Int = 30) {
        let task = Task(title: title, notes: notes, priority: priority, category: category, dueDate: dueDate, estimatedDuration: estimatedDuration)
        tasks.append(task)
        saveData()
    }
    
    func toggleTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
            tasks[index].completedAt = tasks[index].isCompleted ? Date() : nil
            saveData()
        }
    }
    
    func deleteTask(_ task: Task) {
        tasks.removeAll { $0.id == task.id }
        saveData()
    }
    
    func addFocusSession(_ duration: TimeInterval) {
        let session = FocusSession(duration: duration, completedAt: Date())
        focusSessions.append(session)
        updateBadges()
        saveData()
    }
    
    func resetProgress() {
        tasks.removeAll()
        focusSessions.removeAll()
        earnedBadges.removeAll()
        saveData()
    }
    
    var completedTasksCount: Int {
        tasks.filter { $0.isCompleted }.count
    }
    
    var totalTasksCount: Int {
        tasks.count
    }
    
    var completionPercentage: Double {
        guard totalTasksCount > 0 else { return 0 }
        return Double(completedTasksCount) / Double(totalTasksCount)
    }
    
    var totalFocusTime: TimeInterval {
        focusSessions.reduce(0) { $0 + $1.duration }
    }
    
    private func updateBadges() {
        let sessionCount = focusSessions.count
        for badge in Badge.allCases {
            if sessionCount >= badge.requirement {
                earnedBadges.insert(badge)
            }
        }
    }
    
    private func saveData() {
        if let encoded = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(encoded, forKey: "tasks")
        }
        if let encoded = try? JSONEncoder().encode(focusSessions) {
            UserDefaults.standard.set(encoded, forKey: "focusSessions")
        }
        if let encoded = try? JSONEncoder().encode(Array(earnedBadges)) {
            UserDefaults.standard.set(encoded, forKey: "earnedBadges")
        }
        UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
    }
    
    private func loadData() {
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        
        if let data = UserDefaults.standard.data(forKey: "tasks"),
           let decoded = try? JSONDecoder().decode([Task].self, from: data) {
            tasks = decoded
        }
        
        if let data = UserDefaults.standard.data(forKey: "focusSessions"),
           let decoded = try? JSONDecoder().decode([FocusSession].self, from: data) {
            focusSessions = decoded
        }
        
        if let data = UserDefaults.standard.data(forKey: "earnedBadges"),
           let decoded = try? JSONDecoder().decode([Badge].self, from: data) {
            earnedBadges = Set(decoded)
        }
        
        updateBadges()
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - App Theme
struct AppTheme {
    static let background = Color(hex: "0e0e0e")
    static let primaryButton = Color(hex: "28a809")
    static let secondaryButton = Color(hex: "e6053a")
    static let accent = Color(hex: "d17305")
    static let textColor = Color(hex: "ffffff")
}

// MARK: - Onboarding View
struct OnboardingView: View {
    @StateObject private var appState = AppStateManager()
    @State private var currentPage = 0
    @State private var showMainApp = false
    
    private let pages = [
        ("Focus on what matters", "Plan your day with intention and clarity"),
        ("Build lasting habits", "Track your progress and stay consistent"),
        ("Visualize your growth", "See your achievements come to life")
    ]
    
    var body: some View {
        if showMainApp {
            MainAppView()
                .environmentObject(appState)
        } else {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                VStack(spacing: 40) {
                    Spacer()
                    
                    VStack(spacing: 30) {
                        Image(systemName: currentPage == 0 ? "target" : currentPage == 1 ? "chart.line.uptrend.xyaxis" : "trophy.fill")
                            .font(.system(size: 80))
                            .foregroundColor(AppTheme.accent)
                            .scaleEffect(1.0)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: currentPage)
                        
                        VStack(spacing: 16) {
                            Text(pages[currentPage].0)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(AppTheme.textColor)
                                .multilineTextAlignment(.center)
                            
                            Text(pages[currentPage].1)
                                .font(.body)
                                .foregroundColor(AppTheme.textColor.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                        .animation(.easeInOut(duration: 0.5), value: currentPage)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 20) {
                        HStack(spacing: 8) {
                            ForEach(0..<pages.count, id: \.self) { index in
                                Circle()
                                    .fill(index == currentPage ? AppTheme.accent : AppTheme.textColor.opacity(0.3))
                                    .frame(width: 8, height: 8)
                                    .scaleEffect(index == currentPage ? 1.2 : 1.0)
                                    .animation(.spring(response: 0.3), value: currentPage)
                            }
                        }
                        
                        HStack(spacing: 20) {
                            if currentPage > 0 {
                                Button("Previous") {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        currentPage -= 1
                                    }
                                }
                                .foregroundColor(AppTheme.textColor.opacity(0.7))
                            }
                            
                            Spacer()
                            
                            Button(currentPage == pages.count - 1 ? "Start" : "Next") {
                                if currentPage == pages.count - 1 {
                                    appState.completeOnboarding()
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        showMainApp = true
                                    }
                                } else {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        currentPage += 1
                                    }
                                }
                            }
                            .padding(.horizontal, 30)
                            .padding(.vertical, 12)
                            .background(AppTheme.primaryButton)
                            .foregroundColor(.white)
.font(.system(size: 16, weight: .semibold))
                            .cornerRadius(25)
                            .scaleEffect(1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: currentPage)
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 50)
                }
            }
        }
    }
}

// MARK: - Main App View
struct MainAppView: View {
    @EnvironmentObject var appState: AppStateManager
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
            
            FocusView()
                .tabItem {
                    Image(systemName: "timer")
                    Text("Focus")
                }
                .tag(1)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Stats")
                }
                .tag(2)
        }
        .accentColor(AppTheme.primaryButton)
        .preferredColorScheme(.dark)
    }
}

// MARK: - Dashboard View
struct DashboardView: View {
    @EnvironmentObject var appState: AppStateManager
    @State private var showingAddTask = false
    @State private var newTaskTitle = ""
    @State private var selectedFilter: TaskFilter = .all
    @State private var selectedSort: TaskSort = .priority
    @State private var showingFilters = false
    
    enum TaskFilter: String, CaseIterable {
        case all = "All"
        case pending = "Pending"
        case completed = "Completed"
        case overdue = "Overdue"
        case today = "Due Today"
    }
    
    enum TaskSort: String, CaseIterable {
        case priority = "Priority"
        case dueDate = "Due Date"
        case category = "Category"
        case created = "Created"
        
        var icon: String {
            switch self {
            case .priority: return "exclamationmark.triangle"
            case .dueDate: return "calendar"
            case .category: return "folder"
            case .created: return "clock"
            }
        }
    }
    
    private var filteredTasks: [Task] {
        let filtered = appState.tasks.filter { task in
            switch selectedFilter {
            case .all:
                return true
            case .pending:
                return !task.isCompleted
            case .completed:
                return task.isCompleted
            case .overdue:
                return task.isOverdue
            case .today:
                guard let dueDate = task.dueDate else { return false }
                return Calendar.current.isDateInToday(dueDate)
            }
        }
        
        return filtered.sorted { task1, task2 in
            switch selectedSort {
            case .priority:
                let priority1 = TaskPriority.allCases.firstIndex(of: task1.priority) ?? 0
                let priority2 = TaskPriority.allCases.firstIndex(of: task2.priority) ?? 0
                return priority1 > priority2
            case .dueDate:
                guard let date1 = task1.dueDate, let date2 = task2.dueDate else {
                    return task1.dueDate != nil
                }
                return date1 < date2
            case .category:
                return task1.category.rawValue < task2.category.rawValue
            case .created:
                return task1.createdAt > task2.createdAt
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header with progress
                        VStack(spacing: 16) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Today's Progress")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(AppTheme.textColor)
                                    
                                    Text("\(appState.completedTasksCount) of \(appState.totalTasksCount) tasks completed")
                                        .font(.subheadline)
                                        .foregroundColor(AppTheme.textColor.opacity(0.7))
                                }
                                
                                Spacer()
                            }
                            
                            // Progress Bar
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Completion")
                                        .font(.subheadline)
                                        .foregroundColor(AppTheme.textColor.opacity(0.8))
                                    
                                    Spacer()
                                    
                                    Text("\(Int(appState.completionPercentage * 100))%")
                                        .font(.subheadline)
            .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(AppTheme.primaryButton)
                                }
                                
                                ProgressView(value: appState.completionPercentage)
                                    .progressViewStyle(LinearProgressViewStyle(tint: AppTheme.primaryButton))
                                    .scaleEffect(x: 1, y: 2, anchor: .center)
                                    .animation(.easeInOut(duration: 0.5), value: appState.completionPercentage)
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(16)
                        
                        // Filter and Sort Controls
                        VStack(spacing: 16) {
                            HStack {
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        showingFilters.toggle()
                                    }
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "line.horizontal.3.decrease.circle")
                                            .font(.system(size: 16))
                                        
                                        Text("Filter & Sort")
                                            .font(.system(size: 14, weight: .medium))
                                    }
                                    .foregroundColor(AppTheme.textColor.opacity(0.8))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(12)
                                }
                                
                                Spacer()
                                
                                Text("\(filteredTasks.count) tasks")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(AppTheme.textColor.opacity(0.6))
                            }
                            
                            if showingFilters {
                                VStack(spacing: 12) {
                                    // Filter options
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 12) {
                                            ForEach(TaskFilter.allCases, id: \.self) { filter in
                                                Button(filter.rawValue) {
                                                    selectedFilter = filter
                                                }
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 8)
                                                .background(selectedFilter == filter ? AppTheme.primaryButton : Color.white.opacity(0.1))
                                                .foregroundColor(selectedFilter == filter ? .white : AppTheme.textColor.opacity(0.8))
                                                .font(.system(size: 12, weight: .medium))
                                                .cornerRadius(16)
                                                .animation(.easeInOut(duration: 0.2), value: selectedFilter)
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                    
                                    // Sort options
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 12) {
                                            ForEach(TaskSort.allCases, id: \.self) { sort in
                                                Button(action: {
                                                    selectedSort = sort
                                                }) {
                                                    HStack(spacing: 6) {
                                                        Image(systemName: sort.icon)
                                                            .font(.system(size: 10))
                                                        
                                                        Text(sort.rawValue)
                                                    }
                                                }
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(selectedSort == sort ? AppTheme.accent : Color.white.opacity(0.1))
                                                .foregroundColor(selectedSort == sort ? .white : AppTheme.textColor.opacity(0.8))
                                                .font(.system(size: 11, weight: .medium))
                                                .cornerRadius(12)
                                                .animation(.easeInOut(duration: 0.2), value: selectedSort)
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                                .transition(.opacity.combined(with: .scale))
                            }
                        }
                        .padding(.horizontal)
                        
                        // Tasks Section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Tasks")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(AppTheme.textColor)
                                
                                Spacer()
                                
                                Button("Add Task") {
                                    showingAddTask = true
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(AppTheme.primaryButton)
                                .foregroundColor(.white)
                                .font(.system(size: 16, weight: .medium))
                                .cornerRadius(20)
                                .scaleEffect(1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: showingAddTask)
                            }
                            
                            if filteredTasks.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: appState.tasks.isEmpty ? "checklist" : "magnifyingglass")
                                        .font(.system(size: 50))
                                        .foregroundColor(AppTheme.textColor.opacity(0.3))
                                    
                                    Text(appState.tasks.isEmpty ? "No tasks yet" : "No matching tasks")
                                        .font(.headline)
                                        .foregroundColor(AppTheme.textColor.opacity(0.6))
                                    
                                    Text(appState.tasks.isEmpty ? "Add your first task to get started" : "Try adjusting your filters")
                                        .font(.subheadline)
                                        .foregroundColor(AppTheme.textColor.opacity(0.4))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                            } else {
                                LazyVStack(spacing: 12) {
                                    ForEach(filteredTasks) { task in
                                        TaskRowView(task: task)
                                            .environmentObject(appState)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.top)
                }
            }
            .navigationTitle("FlowBoard")
            .navigationBarTitleDisplayMode(.large)
            .preferredColorScheme(.dark)
        }
        .sheet(isPresented: $showingAddTask) {
            AddTaskView(newTaskTitle: $newTaskTitle) { title, notes, priority, category, dueDate, duration in
                appState.addTask(title, notes: notes, priority: priority, category: category, dueDate: dueDate, estimatedDuration: duration)
                newTaskTitle = ""
                showingAddTask = false
            }
        }
    }
}

// MARK: - Task Row View
struct TaskRowView: View {
    let task: Task
    @EnvironmentObject var appState: AppStateManager
    @State private var isPressed = false
    @State private var showingDetails = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                // Completion button
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        appState.toggleTask(task)
                    }
                }) {
                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundColor(task.isCompleted ? AppTheme.primaryButton : AppTheme.textColor.opacity(0.4))
                        .scaleEffect(isPressed ? 1.2 : 1.0)
                        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: task.isCompleted)
                }
                .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
                    withAnimation(.spring(response: 0.2)) {
                        isPressed = pressing
                    }
                }, perform: {})
                
                VStack(alignment: .leading, spacing: 8) {
                    // Main task content
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(task.title)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(task.isCompleted ? AppTheme.textColor.opacity(0.6) : AppTheme.textColor)
                                .strikethrough(task.isCompleted)
                                .lineLimit(2)
                            
                            if !task.notes.isEmpty {
                                Text(task.notes)
                                    .font(.caption)
                                    .foregroundColor(AppTheme.textColor.opacity(0.5))
                                    .lineLimit(1)
                            }
                        }
                        
                        Spacer()
                        
                        // Priority indicator
                        VStack(spacing: 4) {
                            Image(systemName: task.priority.icon)
                                .font(.caption)
                                .foregroundColor(task.priority.color)
                            
                            Text(task.priority.rawValue)
                                .font(.system(size: 8, weight: .medium))
                                .foregroundColor(task.priority.color)
                        }
                    }
                    
                    // Task metadata row
                    HStack(spacing: 16) {
                        // Category
                        HStack(spacing: 4) {
                            Image(systemName: task.category.icon)
                                .font(.system(size: 10))
                                .foregroundColor(task.category.color)
                            
                            Text(task.category.rawValue)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(task.category.color)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(task.category.color.opacity(0.1))
                        .cornerRadius(8)
                        
                        // Duration
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.system(size: 10))
                                .foregroundColor(AppTheme.textColor.opacity(0.6))
                            
                            Text(task.estimatedDurationText)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(AppTheme.textColor.opacity(0.6))
                        }
                        
                        // Due date
                        if task.dueDate != nil {
                            HStack(spacing: 4) {
                                Image(systemName: task.isOverdue ? "exclamationmark.triangle.fill" : "calendar")
                                    .font(.system(size: 10))
                                    .foregroundColor(task.isOverdue ? AppTheme.secondaryButton : AppTheme.textColor.opacity(0.6))
                                
                                Text(task.dueDateText)
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(task.isOverdue ? AppTheme.secondaryButton : AppTheme.textColor.opacity(0.6))
                            }
                        }
                        
                        Spacer()
                        
                        // Actions
                        HStack(spacing: 12) {
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    showingDetails.toggle()
                                }
                            }) {
                                Image(systemName: showingDetails ? "chevron.up" : "chevron.down")
                                    .font(.system(size: 12))
                                    .foregroundColor(AppTheme.textColor.opacity(0.6))
                            }
                            
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    appState.deleteTask(task)
                                }
                            }) {
                                Image(systemName: "trash")
                                    .font(.system(size: 12))
                                    .foregroundColor(AppTheme.secondaryButton.opacity(0.7))
                            }
                        }
                    }
                }
            }
            .padding()
            
            // Expanded details
            if showingDetails {
                VStack(alignment: .leading, spacing: 12) {
                    Divider()
                        .background(AppTheme.textColor.opacity(0.1))
                    
                    VStack(alignment: .leading, spacing: 8) {
                        if !task.notes.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Notes")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(AppTheme.textColor.opacity(0.8))
                                
                                Text(task.notes)
                                    .font(.system(size: 14))
                                    .foregroundColor(AppTheme.textColor.opacity(0.7))
                            }
                        }
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Created")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(AppTheme.textColor.opacity(0.5))
                                
                                Text(formatDate(task.createdAt))
                                    .font(.system(size: 12))
                                    .foregroundColor(AppTheme.textColor.opacity(0.7))
                            }
                            
                            if let completedAt = task.completedAt {
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("Completed")
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundColor(AppTheme.primaryButton.opacity(0.8))
                                    
                                    Text(formatDate(completedAt))
                                        .font(.system(size: 12))
                                        .foregroundColor(AppTheme.primaryButton)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(task.isCompleted ? 0.02 : 0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(task.isOverdue ? AppTheme.secondaryButton.opacity(0.3) : task.category.color.opacity(0.2), lineWidth: 1)
                )
        )
        .scaleEffect(task.isCompleted ? 0.98 : 1.0)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: task.isCompleted)
        .animation(.easeInOut(duration: 0.3), value: showingDetails)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Add Task View
struct AddTaskView: View {
    @Binding var newTaskTitle: String
    let onAdd: (String, String, TaskPriority, TaskCategory, Date?, Int) -> Void
    @Environment(\.presentationMode) var presentationMode
    
    @State private var taskNotes: String = ""
    @State private var selectedPriority: TaskPriority = .medium
    @State private var selectedCategory: TaskCategory = .personal
    @State private var hasDueDate: Bool = false
    @State private var dueDate: Date = Date().addingTimeInterval(86400) // Tomorrow
    @State private var estimatedDuration: Int = 30
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Task Title
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Task Title")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(AppTheme.textColor)
                            
                            TextField("Enter task description", text: $newTaskTitle)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.body)
                        }
                        
                        // Notes
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes (Optional)")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(AppTheme.textColor)
                            
                            TextField("Additional details...", text: $taskNotes)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.body)
                        }
                        
                        // Priority Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Priority")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(AppTheme.textColor)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                                ForEach(TaskPriority.allCases, id: \.self) { priority in
                                    Button(action: {
                                        selectedPriority = priority
                                    }) {
                                        HStack(spacing: 8) {
                                            Image(systemName: priority.icon)
                                                .font(.system(size: 14))
                                            
                                            Text(priority.rawValue)
                                                .font(.system(size: 14, weight: .medium))
                                        }
                                        .foregroundColor(selectedPriority == priority ? .white : priority.color)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        .background(
                                            selectedPriority == priority ? 
                                            priority.color : priority.color.opacity(0.1)
                                        )
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(priority.color.opacity(0.3), lineWidth: 1)
                                        )
                                    }
                                    .animation(.easeInOut(duration: 0.2), value: selectedPriority)
                                }
                            }
                        }
                        
                        // Category Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Category")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(AppTheme.textColor)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                                ForEach(TaskCategory.allCases, id: \.self) { category in
                                    Button(action: {
                                        selectedCategory = category
                                    }) {
                                        HStack(spacing: 8) {
                                            Image(systemName: category.icon)
                                                .font(.system(size: 14))
                                            
                                            Text(category.rawValue)
                                                .font(.system(size: 14, weight: .medium))
                                        }
                                        .foregroundColor(selectedCategory == category ? .white : category.color)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        .background(
                                            selectedCategory == category ? 
                                            category.color : category.color.opacity(0.1)
                                        )
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(category.color.opacity(0.3), lineWidth: 1)
                                        )
                                    }
                                    .animation(.easeInOut(duration: 0.2), value: selectedCategory)
                                }
                            }
                        }
                        
                        // Due Date
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Due Date")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(AppTheme.textColor)
                                
                                Spacer()
                                
                                Toggle("", isOn: $hasDueDate)
                                    .scaleEffect(0.8)
                            }
                            
                            if hasDueDate {
                                DatePicker("Select due date", selection: $dueDate, displayedComponents: [.date])
                                    .datePickerStyle(WheelDatePickerStyle())
                                    .labelsHidden()
                                    .transition(.opacity.combined(with: .scale))
                            }
                        }
                        
                        // Estimated Duration
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Estimated Duration")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(AppTheme.textColor)
                            
                            VStack(spacing: 8) {
                                HStack {
                                    Text("15 min")
                                        .font(.caption)
                                        .foregroundColor(AppTheme.textColor.opacity(0.6))
                                    
                                    Spacer()
                                    
                                    Text("\(estimatedDuration) min")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(AppTheme.primaryButton)
                                    
                                    Spacer()
                                    
                                    Text("180 min")
                                        .font(.caption)
                                        .foregroundColor(AppTheme.textColor.opacity(0.6))
                                }
                                
                                Slider(value: Binding(
                                    get: { Double(estimatedDuration) },
                                    set: { estimatedDuration = Int($0) }
                                ), in: 15...180, step: 15)
                                .accentColor(AppTheme.primaryButton)
                            }
                        }
                        
                        Spacer(minLength: 50)
                    }
                    .padding()
                }
            }
            .navigationTitle("Add Task")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Add") {
                    onAdd(
                        newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines),
                        taskNotes.trimmingCharacters(in: .whitespacesAndNewlines),
                        selectedPriority,
                        selectedCategory,
                        hasDueDate ? dueDate : nil,
                        estimatedDuration
                    )
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            )
            .preferredColorScheme(.dark)
        }
    }
}

// MARK: - Focus View
struct FocusView: View {
    @EnvironmentObject var appState: AppStateManager
    @State private var timeRemaining: TimeInterval = 25 * 60 // 25 minutes
    @State private var isActive = false
    @State private var timer: Timer?
    @State private var sessionDuration: TimeInterval = 25 * 60
    
    private let focusDurations: [TimeInterval] = [15 * 60, 25 * 60, 45 * 60] // 15, 25, 45 minutes
    private let focusDurationNames = ["15 min", "25 min", "45 min"]
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Timer Circle
                        VStack(spacing: 24) {
                            ZStack {
                                Circle()
                                    .stroke(AppTheme.textColor.opacity(0.1), lineWidth: 8)
                                    .frame(width: 250, height: 250)
                                
                                Circle()
                                    .trim(from: 0, to: CGFloat(1 - (timeRemaining / sessionDuration)))
                                    .stroke(AppTheme.primaryButton, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                                    .frame(width: 250, height: 250)
                                    .rotationEffect(.degrees(-90))
                                    .animation(.linear(duration: 1), value: timeRemaining)
                                
                                VStack(spacing: 8) {
                                    Text(timeString(from: timeRemaining))
                                        .font(.system(size: 36, weight: .bold, design: .monospaced))
                                        .foregroundColor(AppTheme.textColor)
                                    
                                    Text(isActive ? "Focus Time" : "Ready to Focus")
                                        .font(.subheadline)
                                        .foregroundColor(AppTheme.textColor.opacity(0.7))
                                }
                            }
                        }
                        
                        // Duration Selection
                        if !isActive {
                            VStack(spacing: 16) {
                                Text("Session Duration")
                                    .font(.headline)
                                    .foregroundColor(AppTheme.textColor)
                                
                                HStack(spacing: 12) {
                                    ForEach(Array(focusDurations.enumerated()), id: \.offset) { index, duration in
                                        Button(focusDurationNames[index]) {
                                            sessionDuration = duration
                                            timeRemaining = duration
                                        }
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 10)
                                        .background(sessionDuration == duration ? AppTheme.primaryButton : Color.white.opacity(0.1))
                                        .foregroundColor(sessionDuration == duration ? .white : AppTheme.textColor)
        .font(.system(size: 16, weight: .medium))
                                        .cornerRadius(20)
                                        .animation(.easeInOut(duration: 0.2), value: sessionDuration)
                                    }
                                }
                            }
                        }
                        
                        // Control Buttons
                        VStack(spacing: 16) {
                            if !isActive {
                                Button("Start Session") {
                                    startTimer()
                                }
                                .padding(.horizontal, 40)
                                .padding(.vertical, 16)
                                .background(AppTheme.primaryButton)
                                .foregroundColor(.white)
                                .font(.headline)
    .font(.system(size: 16, weight: .semibold))
                                .cornerRadius(25)
                                .scaleEffect(1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isActive)
                            } else {
                                HStack(spacing: 20) {
                                    Button("Pause") {
                                        pauseTimer()
                                    }
                                    .padding(.horizontal, 30)
                                    .padding(.vertical, 12)
                                    .background(AppTheme.accent)
                                    .foregroundColor(.white)
    .font(.system(size: 16, weight: .medium))
                                    .cornerRadius(20)
                                    
                                    Button("End") {
                                        endTimer()
                                    }
                                    .padding(.horizontal, 30)
                                    .padding(.vertical, 12)
                                    .background(AppTheme.secondaryButton)
                                    .foregroundColor(.white)
    .font(.system(size: 16, weight: .medium))
                                    .cornerRadius(20)
                                }
                            }
                        }
                        
                        // Session Stats
                        if appState.focusSessions.count > 0 {
                            VStack(spacing: 12) {
                                Text("Today's Sessions")
                                    .font(.headline)
                                    .foregroundColor(AppTheme.textColor)
                                
                                HStack(spacing: 30) {
                                    VStack(spacing: 4) {
                                        Text("\(appState.focusSessions.count)")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(AppTheme.primaryButton)
                                        
                                        Text("Sessions")
                                            .font(.caption)
                                            .foregroundColor(AppTheme.textColor.opacity(0.7))
                                    }
                                    
                                    VStack(spacing: 4) {
                                        Text(timeString(from: appState.totalFocusTime))
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(AppTheme.accent)
                                        
                                        Text("Total Time")
                                            .font(.caption)
                                            .foregroundColor(AppTheme.textColor.opacity(0.7))
                                    }
                                }
                                .padding()
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(16)
                            }
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .padding()
                }
            }
            .navigationTitle("Focus")
            .navigationBarTitleDisplayMode(.large)
            .preferredColorScheme(.dark)
        }
    }
    
    private func startTimer() {
        isActive = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                completeSession()
            }
        }
    }
    
    private func pauseTimer() {
        isActive = false
        timer?.invalidate()
        timer = nil
    }
    
    private func endTimer() {
        isActive = false
        timer?.invalidate()
        timer = nil
        
        // Record partial session if significant time was spent
        let timeSpent = sessionDuration - timeRemaining
        if timeSpent >= 60 { // At least 1 minute
            appState.addFocusSession(timeSpent)
        }
        
        timeRemaining = sessionDuration
    }
    
    private func completeSession() {
        isActive = false
        timer?.invalidate()
        timer = nil
        
        appState.addFocusSession(sessionDuration)
        timeRemaining = sessionDuration
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @EnvironmentObject var appState: AppStateManager
    @State private var showingResetAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Statistics Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Statistics")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(AppTheme.textColor)
                            
                            VStack(spacing: 12) {
                                StatRowView(title: "Tasks Completed", value: "\(appState.completedTasksCount)")
                                StatRowView(title: "Total Tasks", value: "\(appState.totalTasksCount)")
                                StatRowView(title: "Focus Sessions", value: "\(appState.focusSessions.count)")
                                StatRowView(title: "Total Focus Time", value: timeString(from: appState.totalFocusTime))
                                StatRowView(title: "Completion Rate", value: "\(Int(appState.completionPercentage * 100))%")
                            }
                            .padding()
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(16)
                        }
                        
                        // Badges Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Achievements")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(AppTheme.textColor)
                            
                            if appState.earnedBadges.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "trophy")
                                        .font(.system(size: 40))
                                        .foregroundColor(AppTheme.textColor.opacity(0.3))
                                    
                                    Text("No badges earned yet")
                                        .font(.subheadline)
                                        .foregroundColor(AppTheme.textColor.opacity(0.6))
                                    
                                    Text("Complete focus sessions to earn badges")
                                        .font(.caption)
                                        .foregroundColor(AppTheme.textColor.opacity(0.4))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 30)
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(16)
                            } else {
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                                    ForEach(Badge.allCases, id: \.self) { badge in
                                        BadgeView(badge: badge, isEarned: appState.earnedBadges.contains(badge))
                                    }
                                }
                                .padding()
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(16)
                            }
                        }
                        
                        // Actions Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Actions")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(AppTheme.textColor)
                            
                            Button("Reset Progress") {
                                showingResetAlert = true
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppTheme.secondaryButton)
                            .foregroundColor(.white)
.font(.system(size: 16, weight: .medium))
                            .cornerRadius(12)
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .padding()
                }
            }
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.large)
            .preferredColorScheme(.dark)
        }
        .alert("Reset Progress", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                appState.resetProgress()
            }
        } message: {
            Text("This will permanently delete all your tasks, focus sessions, and badges. This action cannot be undone.")
        }
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

// MARK: - Stat Row View
struct StatRowView: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.body)
                .foregroundColor(AppTheme.textColor.opacity(0.8))
            
            Spacer()
            
            Text(value)
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(AppTheme.primaryButton)
        }
    }
}

// MARK: - Badge View
struct BadgeView: View {
    let badge: Badge
    let isEarned: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: badge.icon)
                .font(.system(size: 30))
                .foregroundColor(isEarned ? badge.color : AppTheme.textColor.opacity(0.3))
            
            Text(badge.rawValue)
                .font(.caption)
.font(.system(size: 16, weight: .medium))
                .foregroundColor(isEarned ? AppTheme.textColor : AppTheme.textColor.opacity(0.5))
                .multilineTextAlignment(.center)
            
            Text("\(badge.requirement) sessions")
                .font(.caption2)
                .foregroundColor(AppTheme.textColor.opacity(0.4))
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(isEarned ? 0.1 : 0.02))
        .cornerRadius(12)
        .scaleEffect(isEarned ? 1.0 : 0.95)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isEarned)
    }
}

struct ContentView: View {
    @StateObject private var appState = AppStateManager()
    
    var body: some View {
        Group {
            if appState.hasCompletedOnboarding {
                MainAppView()
                    .environmentObject(appState)
            } else {
                OnboardingView()
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
