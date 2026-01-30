# game_event.gd
extends Node

# 游戏投掷物逻辑
signal signal_object_merged(new_data: ThrowableData, merge_score: int)
signal signal_body_danger_zone(body: BaseThrowable)
signal signal_body_out_danger_zone(body: BaseThrowable)

# 关卡管理器逻辑
signal signal_level_loaded(config: LevelConfig)
signal signal_score_changed(new_score: int)
signal signal_show_fail(reason: String)
signal signal_show_succeed(stars: int)
signal signal_retry_current_level()
signal signal_start_next_level()
# 失败信号
signal signal_fail_to_levelmanager(fail_reason: String)

# 存储信号
signal signal_save_def()
signal signal_save_specific()

# 选关界面相关
signal signal_season_button_pressed(season_id: String, lock: bool)
