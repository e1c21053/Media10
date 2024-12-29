import cv2
import mediapipe as mp
import time
import threading
mode = {
    "idle": "idle",
    "push_ups": "push_ups",
    "squats": "squats",
    "crunches": "crunches",
}


class ExerciseRecognizer:
    def __init__(self):
        self._mp_pose = mp.solutions.pose
        self._pose = self._mp_pose.Pose()
        self._mp_drawing = mp.solutions.drawing_utils

        self.push_up_stage = None
        self.push_up_count = 0
        self.last_push_up_time = 0

        self.squat_stage = None
        self.squat_count = 0
        self.last_squat_time = 0

        self.crunch_stage = None
        self.crunch_count = 0
        self.last_crunch_time = 0

        self.debug_mode = False

    def reset_count(self):
        self.push_up_count = 0
        self.squat_count = 0
        self.crunch_count = 0

    def recognize_exercise(self, frame: cv2.VideoCapture, mode: str) -> cv2.VideoCapture:
        frame_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        results = self._pose.process(frame_rgb)

        if results.pose_landmarks:
            self._mp_drawing.draw_landmarks(
                frame, results.pose_landmarks, self._mp_pose.POSE_CONNECTIONS)
        if not results.pose_landmarks:
            return frame
        if mode == "push_ups":
            self.push_ups(results.pose_landmarks, frame)
        elif mode == "squats":
            self.squats(results.pose_landmarks, frame)
        elif mode == "crunches":
            self.crunches(results.pose_landmarks, frame)

        return frame

    # 腕立て
    def push_ups(self, landmarks, frame):
        # 両手と顔の距離で判定する
        nose = landmarks.landmark[self._mp_pose.PoseLandmark.NOSE]
        left_wrist = landmarks.landmark[self._mp_pose.PoseLandmark.LEFT_WRIST]
        right_wrist = landmarks.landmark[self._mp_pose.PoseLandmark.RIGHT_WRIST]

        wrist_center = self.calculate_center(left_wrist, right_wrist)
        nose_center = (nose.x, nose.y)
        distance = self.calculate_distance(wrist_center, nose_center)
        current_time = time.time()
        if distance < 0.15:
            self.push_up_stage = "down"
        elif distance > 0.25 and self.push_up_stage == "down":
            if current_time - self.last_push_up_time >= 0.5:
                self.push_up_count += 1
                self.last_push_up_time = time.time()
                print(f"Push up count: {self.push_up_count}")
                self.push_up_stage = "up"
        if self.debug_mode:
            self.debug_display_pos(
                [(wrist_center, "wrist_center"), (nose_center, "nose_center"), (self.calculate_center(wrist_center, nose_center), f"Distance: {distance:.2f}")], frame)
            self.debug_display_attrs(frame)

    # スクワット
    def squats(self, landmarks, frame):
        # 腰の位置、と足首の中心位置で判定する
        left_hip = landmarks.landmark[self._mp_pose.PoseLandmark.LEFT_HIP]
        right_hip = landmarks.landmark[self._mp_pose.PoseLandmark.RIGHT_HIP]
        left_ankle = landmarks.landmark[self._mp_pose.PoseLandmark.LEFT_ANKLE]
        right_ankle = landmarks.landmark[self._mp_pose.PoseLandmark.RIGHT_ANKLE]

        hip_center = self.calculate_center(left_hip, right_hip)
        ankle_center = self.calculate_center(left_ankle, right_ankle)
        distance = self.calculate_distance(hip_center, ankle_center)
        # self.display_debug_info(hip_center, ankle_center, frame)
        if self.debug_mode:
            self.debug_display_pos(
                [(hip_center, "hip_center"), (ankle_center, "ankle_center")], frame)
            self.debug_display_attrs(frame)
        current_time = time.time()
        if distance < 0.3:
            self.squat_stage = "down"
        elif distance > 0.3 and self.squat_stage == "down":
            if current_time - self.last_squat_time >= 0.5:  # 0.5 sec
                self.squat_stage = "up"
                self.squat_count += 1
                self.last_squat_time = current_time
                print(f"Squat count: {self.squat_count}")
    # 腹筋

    def crunches(self, landmarks, frame):
        # 膝と頭の距離で判定する
        left_knee = landmarks.landmark[self._mp_pose.PoseLandmark.LEFT_KNEE]
        right_knee = landmarks.landmark[self._mp_pose.PoseLandmark.RIGHT_KNEE]
        left_ear = landmarks.landmark[self._mp_pose.PoseLandmark.LEFT_EAR]
        right_ear = landmarks.landmark[self._mp_pose.PoseLandmark.RIGHT_EAR]

        knee_center = self.calculate_center(left_knee, right_knee)
        ear_center = self.calculate_center(left_ear, right_ear)
        distance = self.calculate_distance(knee_center, ear_center)
        if self.debug_mode:
            self.debug_display_pos(
                [(knee_center, "knee_center"), (ear_center, "ear_center"), (self.calculate_center(knee_center, ear_center), f"Distance: {distance:.2f}")], frame)
            self.debug_display_attrs(frame)
        current_time = time.time()

        if distance > 0.4:
            self.crunch_stage = "down"
        elif distance > 0.3 and self.crunch_stage == "down":
            if current_time - self.last_crunch_time >= 0.5:
                self.crunch_count += 1
                self.last_crunch_time = time.time()
                print(f"Crunch count: {self.crunch_count}")
                self.crunch_stage = "up"

    def debug_display_pos(self, pos_list: list[(tuple, str)], frame: cv2.VideoCapture):
        for i, (pos, name) in enumerate(pos_list):
            pixel = self.convert_to_pixel(pos, frame)
            cv2.circle(frame, pixel, 5, (0, 255, 0), -1)
            cv2.putText(frame, f'{name}: ({pos[0]:.2f}, {pos[1]:.2f})',
                        (int(pixel[0]), int(pixel[1])-10),
                        cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 0), 2)

    def debug_display_attrs(self, frame: cv2.VideoCapture):
        # push_up_countとかを表示する
        attr_dict = {}
        for attr in dir(self):
            if not attr.startswith("__") and not callable(getattr(self, attr)):
                attr_dict[attr] = getattr(self, attr)
        for i, (key, value) in enumerate(attr_dict.items()):
            cv2.putText(frame, f'{key}: {value}', (10, 30 + i*30),
                        cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 0, 255), 2)

    def convert_to_pixel(self, point, frame):
        height, width, _ = frame.shape
        return int(point[0] * width), int(point[1] * height)

    def calculate_center(self, a, b):
        if not isinstance(a, tuple):
            a = (a.x, a.y)
        if not isinstance(b, tuple):
            b = (b.x, b.y)
        # return (a.x + b.x) / 2, (a.y + b.y) / 2
        return (a[0] + b[0]) / 2, (a[1] + b[1]) / 2

    def calculate_distance(self, a, b):
        return ((a[0] - b[0]) ** 2 + (a[1] - b[1]) ** 2) ** 0.5

    # 全身が映っているかどうかを判定する
    def is_whole_body_visible(self, landmarks):
        required_landmarks = [
            self._mp_pose.PoseLandmark.NOSE,
            self._mp_pose.PoseLandmark.LEFT_SHOULDER,
            self._mp_pose.PoseLandmark.RIGHT_SHOULDER,
            self._mp_pose.PoseLandmark.LEFT_HIP,
            self._mp_pose.PoseLandmark.RIGHT_HIP,
            self._mp_pose.PoseLandmark.LEFT_KNEE,
            self._mp_pose.PoseLandmark.RIGHT_KNEE,
            self._mp_pose.PoseLandmark.LEFT_ANKLE,
            self._mp_pose.PoseLandmark.RIGHT_ANKLE
        ]
        for lm in required_landmarks:
            if landmarks.landmark[lm].visibility < 0.5:
                return False
        return True


def main():
    cap = cv2.VideoCapture(0)
    # cap = cv2.VideoCapture(r'.\src\recognizer\test\sq.mp4')
    cap = cv2.VideoCapture(r'.\src\recognizer\test\pu.mp4')
    # cap = cv2.VideoCapture(r'.src\recognizer\test\cr.mp4')
    cap.set(cv2.CAP_PROP_FRAME_WIDTH, 640)
    cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 480)
    recognizer = ExerciseRecognizer()

    # while cap.isOpened():
    while True:
        ret, frame = cap.read()
        if not ret:
            print("Can't receive frame (stream end?). Exiting ...")
            break
        # mode = "idle"
        # mode = "squats"
        mode = "push_ups"
        # mode = "crunches"

        if cv2.waitKey(10) & 0xFF == ord('p'):
            mode = "push_ups"
            recognizer.reset_count()
        elif cv2.waitKey(10) & 0xFF == ord('s'):
            mode = "squats"
            recognizer.reset_count()

        frame = recognizer.recognize_exercise(frame, mode)
        cv2.imshow('Exercise Recognition', frame)

        if cv2.waitKey(10) & 0xFF == ord('q'):
            break

    cap.release()
    cv2.destroyAllWindows()


if __name__ == "__main__":
    main()
